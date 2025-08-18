
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException({required this.message});
}