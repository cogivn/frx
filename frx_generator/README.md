# Frx Generator

A code generator for Dart that adds pattern matching capabilities to sealed classes. Works seamlessly with Freezed or standalone classes to provide powerful pattern matching methods similar to those in functional programming languages.

## Features

- Generates type-safe pattern matching extension methods
- Full support for Dart 3.0 pattern matching syntax
- Works with Freezed classes or regular sealed classes
- Customizable field selection with `@frxParam`
- Automatically runs after Freezed generation to ensure dependency order

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  frx_annotation: ^1.0.1

dev_dependencies:
  frx_generator: ^1.0.2
  build_runner: ^2.4.0
  freezed: ^2.0.0  # If using with Freezed
```

## Usage with Sealed Classes

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'result.frx.g.dart';

@frx
sealed class Result {
  const Result();
}

final class Success extends Result {
  final String value;
  const Success(this.value);
}

final class Error extends Result {
  final String message;
  final int code;
  const Error(this.message, this.code);
}

// Using the generated extension methods
void example() {
  final result = Success("Data loaded");
  
  // Exhaustive pattern matching
  final message = result.when(
    success: (value) => 'Success: $value',
    error: (message, code) => 'Error $code: $message',
  );
  
  // Pattern matching with orElse case
  final message2 = result.maybeWhen(
    success: (value) => 'Success: $value',
    orElse: () => 'Other case',
  );
  
  // Nullable pattern matching
  final message3 = result.whenOrNull(
    success: (value) => 'Success: $value',
  );
}
```

## Usage with Freezed

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frx_annotation/frx_annotation.dart';

part 'user_state.freezed.dart';
part 'user_state.frx.g.dart';

@freezed
@frx
class UserState with _$UserState {
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;
  const factory UserState.loaded(List<User> users) = Loaded;
  const factory UserState.error(String message) = Error;
}

// Using the generated extension methods
void example(UserState state) {
  final widget = state.when(
    initial: () => Text('No data yet'),
    loading: () => CircularProgressIndicator(),
    loaded: (users) => ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => UserTile(users[index]),
    ),
    error: (message) => Text('Error: $message'),
  );
}
```

## Customizing Field Selection

By default, all fields are included in pattern matching. You can customize this:

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'api_result.frx.g.dart';

@FrxAnnotation(generateAllFields: false)
sealed class ApiResult<T> {
  const ApiResult();
  
  factory ApiResult.success(@frxParam T data, String requestId) = Success<T>;
  factory ApiResult.error(@frxParam String message, int statusCode) = Error;
}

// Only `data` and `message` included in pattern matching
void example(ApiResult<User> result) {
  result.when(
    success: (data) => print('Success: $data'),  // requestId not included
    error: (message) => print('Error: $message'), // statusCode not included
  );
}
```

## How it Works

1. Annotate a class with `@frx` or `@FrxAnnotation()`
2. Run the build_runner: `dart run build_runner build`
3. Use the generated extension methods for pattern matching

## Additional Information

- [Source Code](https://github.com/cogivn/frx)
- [Bug/Issue Tracker](https://github.com/cogivn/frx/issues)
- [API Documentation](https://pub.dev/documentation/frx_generator/latest/)
