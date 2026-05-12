class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ConnectionException extends AppException {
  const ConnectionException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ConfigurationException extends AppException {
  const ConfigurationException(super.message);
}

class EmailConfirmationPendingException extends AppException {
  const EmailConfirmationPendingException()
    : super('Email pendiente de confirmación.');
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
