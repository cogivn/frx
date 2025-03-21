/// Default instance of FrxAnnotation with default settings (generateAllFields = true)
const frx = FrxAnnotation();

/// Default instance of FrxParamAnnotation
const frxParam = FrxParamAnnotation();

/// Annotation for classes that should have pattern matching extension methods generated.
///
/// Use [generateAllFields] to control whether all fields should be included
/// in pattern matching (true by default) or only fields annotated with @frxParam.
///
/// Example usage:
/// ```dart
/// @FrxAnnotation(generateAllFields: false)  // Only use fields marked with @frxParam
/// abstract class Result {}
///
/// @frx // Use the default instance (all fields included)
/// abstract class UserState {}
/// ```
class FrxAnnotation {
  /// Whether to generate pattern matching for all fields.
  /// 
  /// If true (default), all constructor parameters will be included in pattern matching.
  /// If false, only parameters annotated with @frxParam will be included.
  final bool generateAllFields;
  
  /// Creates a new annotation for pattern matching code generation.
  /// 
  /// By default, [generateAllFields] is set to true, which means all constructor
  /// parameters will be included in the generated pattern matching methods.
  const FrxAnnotation({this.generateAllFields = true});
}

/// Annotation for parameters that should be included in pattern matching.
///
/// Only needed when FrxAnnotation.generateAllFields is set to false.
///
/// Example usage:
/// ```dart
/// @FrxAnnotation(generateAllFields: false)
/// abstract class Result {
///   factory Result.success(@frxParam String data) = Success;
///   factory Result.error(@frxParam String message, int code) = Error;
/// }
/// ```
class FrxParamAnnotation {
  /// Creates a new annotation for marking parameters to be included in pattern matching.
  const FrxParamAnnotation();
}
