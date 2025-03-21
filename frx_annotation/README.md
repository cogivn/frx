# frx_annotation

A Dart package that provides code generation for union types and pattern matching in Dart applications.

## Features

- Generate pattern matching methods for union types in pure Dart
- Support for when, maybeWhen, and whenOrNull patterns
- Support for map, maybeMap, and mapOrNull patterns
- Type-safe union case handling

## Getting Started

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  frx_annotation: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
  frx_generator: ^1.0.0
```

## Usage

1. Create your union type with the `@frx` annotation:

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'example.frx.g.dart';

@frx
sealed class Union {
  const Union();
}

final class _First extends Union {
  final String value;
  const _First(this.value);
}

final class _Second extends Union {
  const _Second();
}

final class _Third extends Union {
  const _Third();
}
```

2. Run the code generator:

```bash
dart run build_runner build
```

3. Use the generated extension methods:

```dart
void example() {
  final union = _First('hello');
  
  // Using when pattern
  final result = union.when(
    first: (value) => 'First: $value',
    second: () => 'Second',
    third: () => 'Third',
  );

  // Using maybeWhen pattern
  final maybeResult = union.maybeWhen(
    first: (value) => 'First: $value',
    orElse: () => 'Other case',
  );
}
```

## Pattern Matching vs Mapping Methods

When you use the frx_generator, two types of methods are generated:

1. **Pattern Matching Methods**:
   - `when`: Requires handlers for all cases
   - `maybeWhen`: Allows you to handle specific cases with an orElse fallback
   - `whenOrNull`: Lets you handle specific cases, returns null for unhandled cases

2. **Mapping Methods** (only generated for public constructors):
   - `map`: Maps each case to a new value, requires handlers for all public cases
   - `maybeMap`: Maps specific cases with an orElse fallback
   - `mapOrNull`: Maps specific cases, returns null for unhandled cases

Private constructors (those starting with an underscore) will only get pattern matching methods, not mapping methods.

```dart
@frx
sealed class Result {
  // Public constructor - gets both pattern matching and mapping methods
  const factory Result.success(String value) = Success;
  
  // Private constructor - only gets pattern matching methods (when, maybeWhen, whenOrNull)
  const factory Result._failure(String message) = _Failure;
}
```

## Additional Information

- [Homepage](https://github.com/yourusername/frx_annotation)
- [API Documentation](https://pub.dev/documentation/frx_annotation/latest/)
- [Issue Tracker](https://github.com/yourusername/frx_annotation/issues)

## License

```
MIT License

Copyright (c) 2023 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
