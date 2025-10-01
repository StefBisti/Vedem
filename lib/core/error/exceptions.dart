import 'package:equatable/equatable.dart';

class VedemException extends Equatable implements Exception {
  final String message;
  const VedemException({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException({required this.message});
}

class ModelException implements Exception {
  final String message;
  const ModelException({required this.message});
}

class LocalHiveException implements Exception {
  final String message;
  const LocalHiveException({required this.message});
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException({required this.message});
}
