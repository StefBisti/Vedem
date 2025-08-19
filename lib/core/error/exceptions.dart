import 'package:equatable/equatable.dart';

class LocalDatabaseException extends Equatable implements Exception {
  final String message;
  const LocalDatabaseException({required this.message});
  
  @override
  List<Object?> get props => [message];
}
