class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthenticated.']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error.']);
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;
  ValidationException(this.message, {this.errors});
}
