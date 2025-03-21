# FRX (Freezed Extensions)

A powerful pattern matching library for Dart and Flutter that enhances sealed classes and Freezed unions with functional-style pattern matching capabilities.

[![Pub Version](https://img.shields.io/pub/v/frx_annotation)](https://pub.dev/packages/frx_annotation)
[![Pub Version](https://img.shields.io/pub/v/frx_generator)](https://pub.dev/packages/frx_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 🚀 Features

- Generate type-safe pattern matching methods (similar to Kotlin's `when`)
- Support for sealed classes, Freezed unions, and generic types
- Selective parameter extraction with `@frxParam` annotation
- Full compatibility with Dart 3.0 pattern matching syntax
- Control which factory constructors are included with `@frxIgnore`

## 📦 Installation

Add both `frx_annotation` and `frx_generator` to your `pubspec.yaml`:

```yaml
dependencies:
  frx_annotation: ^1.0.2

dev_dependencies:
  frx_generator: ^1.0.4
  build_runner: ^2.4.0
  freezed: ^2.0.0  # If using with Freezed
```

## 🔍 Usage

### With Sealed Classes

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
  const Error(this.message);
}

// Using pattern matching
void example() {
  final result = Success("Data loaded");
  
  final message = result.when(
    success: (value) => 'Success: $value',
    error: (message) => 'Error: $message',
  );
}
```

### With Freezed

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frx_annotation/frx_annotation.dart';

part 'api_result.freezed.dart';
part 'api_result.frx.g.dart';

@freezed
@frx
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = _Success<T>;
  const factory ApiResult.error(String message) = _Error<T>;
  
  @frxIgnore  // This constructor will be excluded from pattern matching
  factory ApiResult.fromJson(Map<String, dynamic> json) => 
      _$ApiResultFromJson(json);
}

// Usage
void handle(ApiResult<User> result) {
  // Handle all cases
  final widget = result.when(
    success: (data) => UserProfile(user: data),
    error: (message) => ErrorDisplay(message: message),
  );
  
  // Handle specific cases with a fallback
  final message = result.maybeWhen(
    success: (data) => 'Welcome, ${data.name}',
    orElse: () => 'Something went wrong',
  );
  
  // Handle only cases you care about (returns null if none match)
  final errorMsg = result.whenOrNull(
    error: (message) => message,
  );
}
```

### With Selective Parameters

```dart
@FrxAnnotation(generateAllFields: false)
@freezed
class NetworkResponse with _$NetworkResponse {
  const factory NetworkResponse.success(
    @frxParam String data,
    int statusCode,
    Map<String, String> headers,
  ) = _Success;
  
  const factory NetworkResponse.error(
    @frxParam String message,
    @frxParam int code,
  ) = _Error;
}

// Usage with selective parameters
void example(NetworkResponse response) {
  // Only selected parameters are included
  final result = response.when(
    success: (data) => 'Got: $data',  // statusCode and headers excluded
    error: (message, code) => 'Error $code: $message',
  );
}
```

### With Generic Types

```dart
@freezed
@frx
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.loading() = Loading<T>;
  const factory Result.error(String message) = Error<T>;
}

// Using generic with custom naming (MemberState)
@Freezed(genericArgumentFactories: true)
@frx
class MemberState<T> with _$MemberState<T> {
  const factory MemberState.loaded(T data) = MLoaded<T>;
  const factory MemberState.loading() = MLoading<T>;
  const factory MemberState.error(String message) = MError<T>;
}
```

## 🔄 Generated Methods

For each annotated class, FRX generates six extension methods:

### Pattern Matching Methods (for all constructors)

- **when**: Exhaustive pattern matching (requires handlers for all cases)
- **maybeWhen**: Pattern matching with an orElse fallback for unspecified cases
- **whenOrNull**: Returns null for unmatched cases (all handlers are optional)

### Mapping Methods (only for public constructors)

- **map**: Maps each case to a new value through type-safe instance access
- **maybeMap**: Maps with an orElse fallback
- **mapOrNull**: Returns null for unmatched cases

## 📘 Documentation

For more detailed documentation, visit:
- [frx_annotation API docs](https://pub.dev/documentation/frx_annotation/latest/)
- [frx_generator API docs](https://pub.dev/documentation/frx_generator/latest/)

## 📋 Compatibility

- Works with Dart 3.0+
- Compatible with Freezed 2.0+
- Supports Flutter and pure Dart projects

## 🔄 Why Use FRX?

FRX brings functional pattern matching to Dart, allowing you to:

1. **Write safer code** with exhaustive pattern matching
2. **Reduce boilerplate** when handling different variants
3. **Integrate smoothly** with Freezed unions
4. **Control** which parameters are included in pattern matching
5. **Exclude** utility constructors from pattern matching

## 📜 License

MIT License - see the [LICENSE](LICENSE) file for details
