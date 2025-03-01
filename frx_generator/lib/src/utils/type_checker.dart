import 'package:analyzer/dart/element/element.dart';
import 'package:frx_annotation/frx_annotation.dart';
import 'package:source_gen/source_gen.dart';

class FrxTypeChecker {
  static const annotation = TypeChecker.fromRuntime(FrxAnnotation);
  static const parameter = TypeChecker.fromRuntime(FrxParamAnnotation);

  static bool hasParameterAnnotation(Element element) {
    return parameter.hasAnnotationOf(element);
  }

  static bool hasClassAnnotation(Element element) {
    return annotation.hasAnnotationOf(element);
  }
}
