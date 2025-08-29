class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException({required this.message});
}

class LocalHiveException implements Exception {
  final String message;
  const LocalHiveException({required this.message});
}
