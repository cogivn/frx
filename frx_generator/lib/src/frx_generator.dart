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
    
    // Read the generateAllFields flag from the annotation
    final generateAllFields = annotation.read('generateAllFields').boolValue;

    // Look for implementing classes in the library
    List<ClassElement> implementingClasses = _findImplementingClasses(element, library);

    if (implementingClasses.isEmpty) {
      // For Freezed classes, the implementations might not be directly visible
      // Try using naming conventions to deduce implementations
      implementingClasses = _findFreezedImplementations(element, library);
      
      if (implementingClasses.isEmpty) {
        throw InvalidGenerationSourceError(
          'No implementing classes found for $className. This might happen if the '
          'generated code is not yet available, or if the Freezed implementation '
          'has a different naming convention.',
          todo: 'Make sure you have run "dart run build_runner build" to generate the Freezed classes first.',
          element: element,
        );
      }
    }

    final isSealed = element.isSealed;
    final constructors = _getFreezedConstructors(
      element, 
      implementingClasses,
      generateAllFields,
    );
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

  /// Finds classes that directly implement or extend the target class.
  List<ClassElement> _findImplementingClasses(ClassElement element, LibraryElement library) {
    return library.topLevelElements
        .whereType<ClassElement>()
        .where(
          (c) =>
              c.interfaces.any((i) => i.element == element) ||
              c.supertype?.element == element,
        )
        .toList();
  }

  /// Attempts to find Freezed implementations based on naming conventions.
  /// 
  /// Freezed typically generates classes with underscore-prefixed names
  /// corresponding to the factory constructor names.
  List<ClassElement> _findFreezedImplementations(ClassElement element, LibraryElement library) {
    // Get all factory constructor names from the annotated class
    final factoryNames = element.constructors
        .where((c) => c.isFactory && !c.name.startsWith('_') && c.name != 'fromJson')
        .map((c) => c.name)
        .toList();
    
    // Look for classes with names matching the pattern _ConstructorName
    return library.topLevelElements
        .whereType<ClassElement>()
        .where((c) {
          // If class name starts with underscore, check if it matches a constructor name
          if (c.name.startsWith('_')) {
            // Remove underscore and check if it matches any capitalized constructor name
            String nameWithoutUnderscore = c.name.substring(1);
            return factoryNames.any((fname) => 
                nameWithoutUnderscore == StringExtension(fname).capitalize() ||
                nameWithoutUnderscore == '${element.name}${StringExtension(fname).capitalize()}');
          }
          return false;
        })
        .toList();
  }

  /// Identifies and extracts constructor information from Freezed classes.
  ///
  /// This method analyzes factory constructors to find their implementing
  /// classes and extract parameter information for pattern matching.
  /// 
  /// If [generateAllFields] is true, all parameters are included. Otherwise,
  /// only parameters annotated with @frxParam are included.
  List<ConstructorInfo> _getFreezedConstructors(
    ClassElement element,
    List<ClassElement> implementingClasses,
    bool generateAllFields,
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

          final filteredParams = generateAllFields
              ? c.parameters
                  .map((p) => ParameterInfo(p.name, p.type.toString()))
                  .toList()
              : c.parameters
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
    // First try to find by redirected constructor
    final redirectedClassName =
        constructor.redirectedConstructor?.returnType.toString();

    if (redirectedClassName != null) {
      // Try to find by exact redirected class name
      final byRedirect = implementingClasses.where(
        (ic) => ic.name == redirectedClassName
      ).toList();
      
      if (byRedirect.isNotEmpty) {
        return byRedirect.first;
      }
    }
    
    // Try to find by naming convention (_ConstructorName)
    final byNamingConvention = implementingClasses.where(
      (ic) => ic.name == '_${StringExtension(constructor.name).capitalize()}'
    ).toList();
    
    if (byNamingConvention.isNotEmpty) {
      return byNamingConvention.first;
    }
    
    // Try to find by class name + constructor name (_ClassConstructorName)
    final byClassAndConstructor = implementingClasses.where(
      (ic) => ic.name == '_${element.name}${StringExtension(constructor.name).capitalize()}'
    ).toList();
    
    if (byClassAndConstructor.isNotEmpty) {
      return byClassAndConstructor.first;
    }

    throw InvalidGenerationSourceError(
      'Could not find implementing class for ${constructor.name}',
      todo: 'Make sure the Freezed class is properly generated. Available classes: '
          '${implementingClasses.map((c) => c.name).join(', ')}',
      element: element,
    );
  }
}

// Add an extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
