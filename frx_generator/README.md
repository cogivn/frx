# Frx Generator

A code generator for Dart that adds pattern matching capabilities to sealed classes. Works seamlessly with Freezed or standalone classes to provide powerful pattern matching methods similar to those in functional programming languages.

## Features

- Generates type-safe pattern matching extension methods
- Full support for Dart 3.0 pattern matching syntax
- Works with Freezed classes or regular sealed classes
- Support for generic classes and type parameters
- Customizable field selection with `@frxParam`
- Automatically runs after Freezed generation to ensure dependency order

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  frx_annotation: ^1.0.1

dev_dependencies:
  frx_generator: ^1.0.5
  build_runner: ^2.4.0
  freezed: ^3.0.0  # Updated to use Freezed 3.x
```

## Usage with Sealed Classes

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'result.g.dart';

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
part 'user_state.g.dart';

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

## Usage with Generic Types

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frx_annotation/frx_annotation.dart';

part 'result.freezed.dart';
part 'result.g.dart';

@freezed
@frx
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.loading() = Loading<T>;
  const factory Result.error(@frxParam String message) = Error<T>;
}

// Using generic classes with custom naming conventions (like MemberState)
@Freezed(genericArgumentFactories: true)
@frx
class MemberState<T> with _$MemberState<T> {
  const factory MemberState.loaded(T data) = MLoaded<T>;
  const factory MemberState.loading() = MLoading<T>;
  const factory MemberState.init() = MInit<T>;
  const factory MemberState.error(@frxParam String message) = MError<T>;
}

void example() {
  final result = Success<User>(User('John'));
  
  // Using pattern matching with generic type
  final message = result.when(
    success: (data) => 'Success: ${data.name}',
    loading: () => 'Loading...',
    error: (message) => 'Error: $message',
  );
  
  // Using pattern matching with custom named generics
  final memberState = MLoaded<Profile>(Profile('Jane'));
  final memberMessage = memberState.when(
    loaded: (data) => 'Loaded: ${data.name}',
    loading: () => 'Loading...',
    init: () => 'Initializing...',
    error: (message) => 'Error: $message',
  );
}
```

## Important Note on Private Constructors

When using Freezed with private factory constructors (prefixed with underscore), the `map`, `maybeMap`, and `mapOrNull` methods **will not be generated**. These mapping methods are only generated for public constructors.

```dart
@freezed
@frx
class UserState with _$UserState {
  // Public constructors - all methods will be generated (when, map, etc.)
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;

  // Private constructors - only pattern matching methods will be generated (when, maybeWhen, whenOrNull)
  // No mapping methods (map, maybeMap, mapOrNull) will be generated
  const factory UserState._authenticated(User user) = _Authenticated;
  const factory UserState._error(String message) = _Error;
}

// Usage example
void example(UserState state) {
  // This works for all constructors (public and private)
  final message = state.when(
    initial: () => 'Initial state',
    loading: () => 'Loading...',
    _authenticated: (user) => 'Welcome, ${user.name}',
    _error: (message) => 'Error: $message',
  );
  
  // This only works for public constructors
  // Private constructors (_authenticated and _error) are not included
  final widget = state.map(
    initial: (state) => Text('Initial'),
    loading: (state) => CircularProgressIndicator(),
    // No _authenticated or _error cases here
  );
}
```

This behavior follows Freezed's approach to privacy, where private constructors are not accessible for direct type casting.

## Ignoring Specific Factory Constructors

You can use the `@frxIgnore` annotation to exclude specific factory constructors from pattern matching generation:

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'api_client.g.dart';

@frx
sealed class ApiResult<T> {
  const ApiResult();
  
  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.error(String message) = Error;
  
  // This constructor will be ignored in pattern matching
  @frxIgnore
  factory ApiResult.fromJson(Map<String, dynamic> json) {
    // ... custom deserialization logic
    return ApiResult.success(data);
  }
}
```

This is useful for utility constructors that shouldn't be part of the pattern matching logic, such as serialization/deserialization methods.

## Customizing Field Selection

By default, all fields are included in pattern matching. You can customize this:

```dart
import 'package:frx_annotation/frx_annotation.dart';

part 'api_result.g.dart';

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

## Pattern Matching Methods

### whenOrNull

The `whenOrNull` method allows handling specific cases with nullable return values:

```dart
@frx
sealed class Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.error(String message) = Error<T>;
}

void example(Result<User> result) {
  final message = result.whenOrNull(
    success: (data) => data.isValid ? 'Valid user' : null, // Can return null
    error: (msg) => msg.isEmpty ? null : 'Error: $msg',    // Can return null
  );
  // message will be null if:
  // 1. No handler matched the case
  // 2. The matching handler returned null
}
```

## How it Works

1. Annotate a class with `@frx` or `@FrxAnnotation()`
2. Run the build_runner: `dart run build_runner build`
3. Use the generated extension methods for pattern matching

## Compatibility

- Works with Dart 3.0+
- Compatible with Freezed 3.0+ 
- Supports Flutter and pure Dart projects

## Additional Information

- [Source Code](https://github.com/cogivn/frx)
- [Bug/Issue Tracker](https://github.com/cogivn/frx/issues)
- [API Documentation](https://pub.dev/documentation/frx_generator/latest/)
