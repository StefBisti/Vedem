class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException({required this.message});
}

class LocalHiveException implements Exception {
  final String message;
  const LocalHiveException({required this.message});
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException({required this.message});
}