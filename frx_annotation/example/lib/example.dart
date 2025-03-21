import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:frx_annotation/frx_annotation.dart';

part 'example.freezed.dart';
part 'example.g.dart';

@frx
@freezed
abstract class Union with _$Union {
  // Correct: Using public factory constructors
  const factory Union.first(@frxParam String value, bool d) = First;
  const factory Union.second(int value) = Second;
  const factory Union.third(bool value) = Third;
}

@freezed
@FrxAnnotation(generateAllFields: false)
sealed class Friend with _$Friend {
  // Correct: Using public factory constructors with public types
  const factory Friend.zone(@frxParam String value, bool d) = FriendZone;
  const factory Friend.best(int value) = BestFriend;
  const factory Friend.close(bool value) = CloseFriend;
}

@frx
sealed class Failure {
  const Failure._(); // Private constructor để ngăn chặn khởi tạo trực tiếp

  const factory Failure.network() = NetworkFailure;
  const factory Failure.timeout() = TimeoutFailure;
  const factory Failure.server() = ServerFailure;
  const factory Failure.unauthorized() = UnauthorizedFailure;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super._();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super._();
}

class ServerFailure extends Failure {
  const ServerFailure() : super._();
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super._();
}

@frx
@freezed
class ApiError with _$ApiError implements PizzaError {
 const ApiError._();

  // Correct: Using public factory constructors
  const factory ApiError.network() = NetworkError;
  const factory ApiError.cancelled() = CancelledError;
  const factory ApiError.unexpected() = UnexpectedError;
  const factory ApiError.unauthorized() = UnauthorizedError;
  
  @override
  // TODO: implement code
  int get code => throw UnimplementedError();
  
  @override
  // TODO: implement message
  String get message => throw UnimplementedError();
}


interface class PizzaError {
  int get code;
  String get message;
}