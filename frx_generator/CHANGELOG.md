## 1.0.1
- Bumped version to 1.0.1
- Made FrxAnnotation constructor public to allow customizing generateAllFields parameter
- Added generateAllFields flag to control whether all fields or only @frxParam fields are included
- Prepared changelog for release

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
