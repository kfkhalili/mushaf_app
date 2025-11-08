import '../exceptions/database_exceptions.dart';

/// Shared utilities for error handling across the application.
///
/// These functions extract common error handling patterns to maintain
/// DRY principles and ensure consistent user-facing error messages.
///
/// WHY: Security - Never expose technical details like paths, stack traces,
/// or internal errors to users. Always provide user-friendly messages.

/// Gets a user-friendly error message from an error object.
///
/// Maps technical database exceptions to generic user-facing messages
/// in Arabic. This ensures users see helpful messages without exposing
/// sensitive technical details.
///
/// WHY: Security - Never expose technical details like paths, stack traces,
/// or internal errors. Always provide user-friendly messages.
String getUserFriendlyErrorMessage(Object error) {
  // Map technical errors to generic user-facing messages
  if (error is DatabaseConnectionException) {
    return 'لا يمكن الاتصال بقاعدة البيانات';
  } else if (error is DatabaseNotInitializedException) {
    return 'قاعدة البيانات غير جاهزة';
  } else if (error is DatabaseNotFoundException) {
    return 'البيانات المطلوبة غير موجودة';
  } else if (error is DatabaseOperationException) {
    return 'حدث خطأ أثناء معالجة البيانات';
  } else if (error is DatabaseConstraintException) {
    return 'خطأ في البيانات';
  } else {
    // Generic message for unknown errors
    // In debug mode, the full error is already logged
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }
}
