# FRX (Freezed Extensions)

A lightweight Dart package that generates extension methods for Freezed classes to make working with optional parameters easier.

## Features

- Generates `maybeWhen` and `whenOrNull` methods for Freezed unions
- Allows selective parameter extraction using `@frxParam` annotation
- Works seamlessly with existing Freezed classes

## Installation

Add both `frx_annotation` and `frx_generator` to your `pubspec.yaml`:

```yaml
dependencies:
  frx_annotation: ^0.0.1

dev_dependencies:
  frx_generator: ^0.0.1
  build_runner: ^2.4.6
```

## Usage

1. First, create your Freezed union class as normal:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frx_annotation/frx_annotation.dart';

part 'example.freezed.dart';

@freezed
@frx
class Result<T> with _$Result<T> {
  const factory Result.success(@frxParam T data) = Success<T>;
  const factory Result.error(@frxParam String message) = Error<T>;
  const factory Result.loading() = Loading<T>;
}
```

2. Run the build_runner to generate the extensions:

```bash
dart run build_runner build
# or
flutter pub run build_runner build
```

3. Use the generated extensions:

```dart
void handleResult(Result<String> result) {
  // Use maybeWhen to handle only specific cases
  final data = result.maybeWhen(
    success: (data) => data,
    error: (message) => 'Error: $message',
  );
  
  // Use whenOrNull when you only care about certain cases
  final errorMessage = result.whenOrNull(
    error: (message) => message,
  );
}
```

## Annotations

- `@frx`: Add this to your Freezed class to generate extensions
- `@frxParam`: Add this to constructor parameters that you want to include in the generated methods

## Examples

### Basic Usage

```dart
@freezed
@frx
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(@frxParam T data) = _Success<T>;
  const factory ApiResult.error(@frxParam String message, int code) = _Error<T>;
  const factory ApiResult.loading() = _Loading<T>;
}

// Usage
final result = ApiResult.success('Hello');

// Only handle success and error cases
final message = result.maybeWhen(
  success: (data) => 'Got data: $data',
  error: (message, _) => 'Error: $message',
);

// Only handle error case
final errorMessage = result.whenOrNull(
  error: (message, _) => message,
);
```

### Multiple Parameters

```dart
@freezed
@frx
class UserState with _$UserState {
  const factory UserState.authenticated(
    @frxParam User user,
    @frxParam String token,
  ) = _Authenticated;
  const factory UserState.unauthenticated() = _Unauthenticated;
}

// Usage
final state = UserState.authenticated(user, 'token123');

final userData = state.maybeWhen(
  authenticated: (user, token) => 'User: ${user.name}, Token: $token',
  orElse: () => 'Not authenticated',
);
```

## License

MIT License - see the [LICENSE](LICENSE) file for details
