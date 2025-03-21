## 1.0.4

- Added support for `@frxIgnore` annotation to exclude specific factory constructors from generation
- Fixed generic type support for custom naming patterns (such as MLoaded<T> in MemberState<T>)
- Updated documentation with examples of using the ignore annotation
- Fixed null-safety issue in pattern matching methods for required parameters
- Removed usage of deprecated withNullability parameter
- Improved error messages for better debugging

## 1.0.3

- Added support for generic classes in Freezed and sealed classes
- Fixed issue with finding implementing classes for generic Freezed classes
- Fixed handling of generic type parameters in pattern matching methods
- Fixed null safety issue in the `when` method implementation
- Removed usage of deprecated `withNullability` parameter
- Improved type safety for generic union types
- Added special handling for Freezed naming conventions with generic classes (e.g., MLoaded<T>)

## 1.0.2

- Changed to use SharedPartBuilder instead of PartBuilder for better compatibility with other generators
- Added build.yaml configuration with proper combining_builder setup
- Fixed issue with detecting implementing classes for Freezed classes
- Improved error messages to help troubleshoot generation problems
- Added required_inputs configuration to ensure frx_generator runs after freezed completes
- Enhanced documentation with more examples and clearer usage instructions

## 1.0.1

- Bumped version to 1.0.1
- Made FrxAnnotation constructor public to allow customizing generateAllFields parameter
- Added generateAllFields flag to control whether all fields or only @frxParam fields are included
- Improved error handling and reporting

## 1.0.0+2

* Enhance generator performance
* Improve error messages and debugging
* Add support for custom serialization
* Update dependencies

## 1.0.0+1

* Fix issue with default value handling for FrxInput
* Improve code generation performance
* Update documentation

## 1.0.0

* Initial release with the following features:
* Generator implementation for union types with @frx annotation
* Support for generating extension methods:
  - when: Exhaustive pattern matching
  - maybeWhen: Pattern matching with orElse case
  - whenOrNull: Nullable pattern matching
  - map: Type-safe case mapping
  - maybeMap: Case mapping with orElse case
  - mapOrNull: Nullable case mapping
* Support for sealed classes and their subclasses
* Support for classes with and without parameters
* Full compatibility with Dart 3.0 pattern matching syntax
