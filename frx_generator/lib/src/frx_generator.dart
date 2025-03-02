import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:frx_annotation/frx_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'generators/method_generator.dart';
import 'models/constructor_info.dart';

/// Generator for creating pattern matching extension methods on classes
/// annotated with [@FrxAnnotation].
///
/// This generator supports sealed classes and their implementations, creating
/// type-safe pattern matching methods similar to those in functional programming
/// languages. It detects implementing classes and their constructors to generate
/// appropriate pattern matching code.
class FrxGenerator extends GeneratorForAnnotation<FrxAnnotation> {
  static const _frxParamChecker = TypeChecker.fromRuntime(FrxParamAnnotation);

  /// Generates extension methods for the annotated element.
  ///
  /// This method analyzes classes with [@FrxAnnotation] and creates extension
  /// methods for pattern matching on their subtypes.
  ///
  /// Throws an [InvalidGenerationSourceError] if:
  /// - The annotated element is not a class
  /// - No implementing classes are found
  /// - No matching implementing class can be found for a constructor
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

    List<ClassElement> implementingClasses = library.topLevelElements
        .whereType<ClassElement>()
        .where(
          (c) =>
              c.interfaces.any((i) => i.element == element) ||
              c.supertype?.element == element,
        )
        .toList();

    if (implementingClasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No implementing classes found for $className.',
        todo: 'Ensure the Freezed class is properly generated.',
        element: element,
      );
    }

    final isSealed = element.isSealed;
    final constructors = _getFreezedConstructors(element, implementingClasses);
    final hasPublicConstructors = constructors.any((c) => !c.isPrivate);

    final buffer = StringBuffer();
    buffer.writeln('extension ${className}X on $className {');
    buffer
        .write(MethodGenerator.generateWhen(className, constructors, isSealed));
    buffer.write(
        MethodGenerator.generateMaybeWhen(className, constructors, isSealed));
    buffer.write(
        MethodGenerator.generateWhenOrNull(className, constructors, isSealed));

    if (hasPublicConstructors) {
      buffer.write(
          MethodGenerator.generateMap(className, constructors, isSealed));
      buffer.write(
          MethodGenerator.generateMaybeMap(className, constructors, isSealed));
      buffer.write(
          MethodGenerator.generateMapOrNull(className, constructors, isSealed));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Identifies and extracts constructor information from Freezed classes.
  ///
  /// This method analyzes factory constructors to find their implementing
  /// classes and extract parameter information for pattern matching.
  List<ConstructorInfo> _getFreezedConstructors(
    ClassElement element,
    List<ClassElement> implementingClasses,
  ) {
    return element.constructors
        .where((c) {
          return c.isFactory &&
              !c.name.startsWith('_') &&
              c.name != 'fromJson' &&
              c != element.unnamedConstructor;
        })
        .map((c) {
          final implementingClass =
              _findImplementingClass(c, implementingClasses, element);

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
        })
        .toList();
  }

  /// Identifies the class that implements a specific factory constructor.
  ///
  /// This method resolves the actual class implementation for a factory constructor
  /// by looking at redirected constructors or naming conventions.
  ClassElement _findImplementingClass(
    ConstructorElement constructor,
    List<ClassElement> implementingClasses,
    ClassElement element,
  ) {
    final redirectedClassName =
        constructor.redirectedConstructor?.returnType.toString();

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
