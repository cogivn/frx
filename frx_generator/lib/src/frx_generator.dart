import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:frx_annotation/frx_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'generators/method_generator.dart';
import 'models/constructor_info.dart';

class FrxGenerator extends GeneratorForAnnotation<FrxAnnotation> {
  static const _frxParamChecker = TypeChecker.fromRuntime(FrxParamAnnotation);

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'Generator cannot target `${element.name}`.',
        todo: 'Remove the FrxAnnotation annotation from `${element.name}`.',
      );
    }

    final className = element.name;
    final library = element.library;
    
    // Find implementing classes directly from library
    final implementingClasses = library.topLevelElements
        .whereType<ClassElement>()
        .where((c) => 
            // c.name.startsWith('_') && // Implementation classes start with _
            c.interfaces.any((i) => i.element == element)) // Implements annotated class
        .toList();

    if (implementingClasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No implementing classes found for $className.',
        todo: 'Ensure the Freezed class is properly generated.',
        element: element,
      );
    }

    final constructors = _getFreezedConstructors(element, implementingClasses);
    final hasPublicConstructors = constructors.any((c) => !c.isPrivate);
    
    final buffer = StringBuffer();
    buffer.writeln('extension ${className}X on $className {');
    buffer.write(MethodGenerator.generateWhen(className, constructors));
    buffer.write(MethodGenerator.generateMaybeWhen(className, constructors));
    buffer.write(MethodGenerator.generateWhenOrNull(className, constructors));
    
    // Only generate map methods if there are public constructors
    if (hasPublicConstructors) {
      buffer.write(MethodGenerator.generateMap(className, constructors));
      buffer.write(MethodGenerator.generateMaybeMap(className, constructors));
      buffer.write(MethodGenerator.generateMapOrNull(className, constructors));
    }
    
    buffer.writeln('}');

    return buffer.toString();
  }

  List<ConstructorInfo> _getFreezedConstructors(
    ClassElement element,
    List<ClassElement> implementingClasses,
  ) {
    return element.constructors.where((c) {
      return c.isFactory &&
          !c.name.startsWith('_') &&
          c.name != 'fromJson' &&
          c != element.unnamedConstructor;
    }).map((c) {
      final implementingClass = _findImplementingClass(c, implementingClasses, element);
      
      final filteredParams = c.parameters
          .where((param) => _frxParamChecker.hasAnnotationOf(param))
          .map((p) => ParameterInfo(p.name, p.type.toString()))
          .toList();

      return ConstructorInfo(
        name: c.name,
        className: implementingClass.name,
        parameters: List.unmodifiable(filteredParams),
        functionType: filteredParams.isEmpty
            ? 'R Function()?'
            : 'R Function(${filteredParams.map((p) => p.type).join(', ')})?',
        parametersPattern: filteredParams.isEmpty
            ? '()'
            : '(${filteredParams.map((p) => ':final ${p.name}').join(', ')})',
        callArguments: filteredParams.map((p) => p.name).join(', '),
        isPrivate: implementingClass.name.startsWith('_'),
      );
    }).toList();
  }

  ClassElement _findImplementingClass(
    ConstructorElement constructor,
    List<ClassElement> implementingClasses,
    ClassElement element,
  ) {
    final redirectedClassName = constructor.redirectedConstructor?.returnType.toString();
    
    return redirectedClassName != null 
        ? implementingClasses.firstWhere(
            (ic) => ic.name == redirectedClassName,
            orElse: () => implementingClasses.firstWhere(
              (ic) => ic.name == '_${constructor.name.capitalize()}',
              orElse: () => throw InvalidGenerationSourceError(
                'Could not find implementing class for ${constructor.name}',
                todo: 'Make sure the Freezed class is properly generated',
                element: element,
              ),
            ),
          )
        : implementingClasses.firstWhere(
            (ic) => ic.name == '_${constructor.name.capitalize()}',
            orElse: () => throw InvalidGenerationSourceError(
              'Could not find implementing class for ${constructor.name}',
              todo: 'Make sure the Freezed class is properly generated',
              element: element,
            ),
          );
  }
}
