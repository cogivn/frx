# frx_generator

Code generator for the frx_annotation package that generates pattern matching methods for union types in Dart.

## Features

- Generates extension methods for sealed classes
- Supports pattern matching with when, maybeWhen, and whenOrNull
- Generates type-safe mapping methods (map, maybeMap, mapOrNull)
- Full support for Dart 3.0 pattern matching syntax

## Installation

Add these dependencies to your package's `pubspec.yaml` file:

```yaml
dependencies:
  frx_annotation: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
  frx_generator: ^1.0.0
```

## Usage

1. Import and use the `@frx` annotation from `frx_annotation`:

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'my_union.frx.g.dart';

@frx
sealed class Result {
  const Result();
}

final class Success extends Result {
  final String value;
  const Success(this.value);
}

final class Error extends Result {
  const Error();
}
```

2. Run the generator:

```bash
dart run build_runner build
```

## Generated API

The generator will create extension methods for pattern matching:

```dart
// Example usage of generated code
void example(Result result) {
  final message = result.when(
    success: (value) => 'Success: $value',
    error: () => 'Error occurred',
  );
  
  final maybeMessage = result.maybeWhen(
    success: (value) => 'Success: $value',
    orElse: () => 'Other case',
  );
}
```

## Additional Information

- [Source Code](https://github.com/yourusername/frx_generator)
- [Bug/Issue Tracker](https://github.com/yourusername/frx_generator/issues)
- [API Documentation](https://pub.dev/documentation/frx_generator/latest/)
