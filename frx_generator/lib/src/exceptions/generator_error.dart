import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class GeneratorError {
  static InvalidGenerationSourceError invalidTarget(Element element) {
    return InvalidGenerationSourceError(
      'Generator cannot target `${element.name}`.',
      todo: 'Remove the FrxAnnotation annotation from `${element.name}`.',
    );
  }

  static InvalidGenerationSourceError noImplementingClasses(String className) {
    return InvalidGenerationSourceError(
      'No implementing classes found for $className.',
      todo: 'Ensure the Freezed class is properly generated.',
    );
  }

  static InvalidGenerationSourceError implementingClassNotFound(
    String constructorName,
    Element element,
  ) {
    return InvalidGenerationSourceError(
      'Could not find implementing class for $constructorName',
      todo: 'Make sure the Freezed class is properly generated',
      element: element,
    );
  }
}
