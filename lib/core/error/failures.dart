import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

const serverFailureMessage = 'ServerFailure';
const cacheFailureMessage = 'Cache Failure';
const invalidInputFailureMessage = 'Invalid Input - The number must be a positive integer';

class ServerFailure extends Failure {
  const ServerFailure() : super(serverFailureMessage);
}

class CacheFailure extends Failure {
  const CacheFailure() : super(cacheFailureMessage);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure() : super(invalidInputFailureMessage);
}
