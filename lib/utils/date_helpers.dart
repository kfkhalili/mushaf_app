/// Date formatting utilities for database operations
///
/// WHY: Centralizes date formatting logic to reduce duplication
/// and ensure consistent date formatting across the codebase.
class DateHelpers {
  /// Formats a DateTime as YYYY-MM-DD for database storage.
  /// WHY: Converts DateTime to ISO date string (date only, no time).
  /// This is the standard format used for date columns in the database.
  static String formatDateForDb(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}
