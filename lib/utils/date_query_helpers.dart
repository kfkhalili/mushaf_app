import '../constants.dart';
import 'date_helpers.dart';

/// WHY: Provides reusable date query patterns to eliminate duplication
/// in date-based database queries across services.
///
/// These helpers centralize common date calculations (last week, this month, etc.)
/// used in reading progress and statistics queries.
class DateQueryHelpers {
  /// WHY: Private constructor to prevent instantiation.
  const DateQueryHelpers._();

  /// Returns the date string for 7 days ago (last week boundary).
  /// Used for "this week" queries that need the start of the week.
  static String lastWeekStart() {
    final weekAgo = DateTime.now().subtract(DateCalculations.weekDuration);
    return DateHelpers.formatDateForDb(weekAgo);
  }

  /// Returns the date string for the start of the current month.
  /// Used for "this month" queries.
  static String thisMonthStart() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return DateHelpers.formatDateForDb(monthStart);
  }

  /// Returns the date string for the start of the current year.
  /// Used for "this year" queries.
  static String thisYearStart() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    return DateHelpers.formatDateForDb(yearStart);
  }

  /// Returns the date string for today.
  /// Used for "today" queries.
  static String today() {
    return DateHelpers.formatDateForDb(DateTime.now());
  }
}
