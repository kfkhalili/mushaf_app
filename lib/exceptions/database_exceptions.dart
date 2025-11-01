// Database-related exceptions hierarchy
// WHY: Provides structured error handling with preserved error context
// instead of generic Exception wrappers that lose type information.

/// Base exception for all database-related errors
abstract class DatabaseException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const DatabaseException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() {
    if (originalError != null) {
      return '$runtimeType: $message\nOriginal error: $originalError';
    }
    return '$runtimeType: $message';
  }
}

/// Thrown when database operation fails (insert, update, delete, query)
class DatabaseOperationException extends DatabaseException {
  const DatabaseOperationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when database is not initialized or not available
class DatabaseNotInitializedException extends DatabaseException {
  const DatabaseNotInitializedException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when database constraint violation occurs (unique key, foreign key, etc.)
class DatabaseConstraintException extends DatabaseException {
  const DatabaseConstraintException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when database connection fails or timeout
class DatabaseConnectionException extends DatabaseException {
  const DatabaseConnectionException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when database data is not found (e.g., query returns no results)
class DatabaseNotFoundException extends DatabaseException {
  const DatabaseNotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });
}
