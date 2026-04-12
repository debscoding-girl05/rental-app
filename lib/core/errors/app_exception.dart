/// Base exception class for all app-specific errors.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException([super.message = 'A network error occurred.']);
}

/// Thrown when authentication fails or the session is invalid.
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

/// Thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

/// Thrown when a server-side error occurs.
class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred.']);
}

/// Thrown for unexpected or unknown errors.
class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
