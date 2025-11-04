import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/date_helpers.dart';
import '../utils/date_query_helpers.dart';
import '../utils/validation_helpers.dart';
import '../exceptions/database_exceptions.dart';
import 'app_data_service.dart';
import 'migration_service.dart';
import 'database_service.dart';

abstract class ReadingProgressService {
  Future<void> recordPageView(int pageNumber);
  Future<ReadingStatistics> getStatistics();
  Future<int> getPagesReadToday();
  Future<int> getCurrentStreak();
  Future<List<int>> getPagesReadByDate(DateTime date);
  Future<Map<DateTime, int>> getWeeklyProgress(); // Date -> pages count
  Future<Map<DateTime, int>> getMonthlyProgress();
  Future<void> clearAllData(); // For privacy/reset
}

/// WHY: Updated to use unified app_data.db instead of separate reading_progress.db.
/// Migrates data from old database on first use.
class SqliteReadingProgressService implements ReadingProgressService {
  final AppDataService _appDataService;
  final DatabaseService? _databaseService;
  final MigrationService _migrationService;
  SharedPreferences? _prefs;
  bool _initialized = false;
  ReadingStatistics? _cachedStatistics;

  SqliteReadingProgressService(this._appDataService, [this._databaseService])
    : _migrationService = MigrationService(_appDataService);

  /// WHY: Sets SharedPreferences for migration (dependency injection).
  /// Called by provider to inject SharedPreferences from provider.
  void setSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// WHY: Ensures unified database is initialized and runs migration if needed.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // WHY: Initialize unified database (creates app_data.db if needed)
    await _appDataService.ensureInitialized();

    // WHY: Run migration from old reading_progress.db if needed
    // Requires SharedPreferences to be set via setSharedPreferences()
    if (_prefs != null) {
      await _migrationService.migrateIfNeeded(_prefs!);
    } else {
      // WHY: Fallback to direct access if provider injection hasn't happened yet
      // This shouldn't happen in normal flow, but provides safety
      final prefs = await SharedPreferences.getInstance();
      await _migrationService.migrateIfNeeded(prefs);
    }

    _initialized = true;
  }

  /// WHY: Getter for database instance from unified service.
  Database get _db => _appDataService.database;

  @override
  Future<void> recordPageView(int pageNumber) async {
    // Validate page number using centralized validation helper
    // WHY: Use centralized validation for consistency and security
    validatePageNumber(pageNumber);

    // Additional validation: Check against actual total pages from database if available
    // WHY: validatePageNumber() checks against 604, but we should respect actual layout
    if (_databaseService != null) {
      try {
        final totalPages = await _databaseService.getTotalPages();
        if (pageNumber > totalPages) {
          throw ArgumentError('Page number must be between 1 and $totalPages');
        }
      } catch (e) {
        // If we can't get total pages, validatePageNumber() already validated against 604
        // This is acceptable fallback behavior
      }
    }

    await _ensureInitialized();

    final now = DateTime.now();
    final sessionDate = DateTime(now.year, now.month, now.day);

    try {
      await _db.insert(DbConstants.readingSessionsTable, {
        DbConstants.sessionDateCol: DateHelpers.formatDateForDb(sessionDate),
        DbConstants.pageNumberCol: pageNumber,
        DbConstants.timestampCol: now.toIso8601String(),
      });

      // Invalidate statistics cache
      _cachedStatistics = null;
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to record page view',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ReadingStatistics> getStatistics() async {
    await _ensureInitialized();

    // Check cache first
    if (_cachedStatistics != null) return _cachedStatistics!;

    try {
      // Calculate from database using SQL aggregations
      final totalPagesRead = await _getUniquePagesCount();
      final pagesToday = await _getPagesToday();
      final pagesThisWeek = await _getPagesThisWeek();
      final pagesThisMonth = await _getPagesThisMonth();
      final daysThisWeek = await _getDaysThisWeek();
      final daysThisMonth = await _getDaysThisMonth();
      final currentStreak = await _calculateCurrentStreak();
      final longestStreak = await _calculateLongestStreak();
      final totalReadingDays = await _getTotalReadingDays();

      // Calculate average pages per day (only for days with reading)
      final averagePagesPerDay = totalReadingDays > 0
          ? totalPagesRead / totalReadingDays
          : 0.0;

      _cachedStatistics = ReadingStatistics(
        totalPagesRead: totalPagesRead,
        totalReadingDays: totalReadingDays,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        pagesToday: pagesToday,
        pagesThisWeek: pagesThisWeek,
        pagesThisMonth: pagesThisMonth,
        daysThisWeek: daysThisWeek,
        daysThisMonth: daysThisMonth,
        averagePagesPerDay: averagePagesPerDay,
      );

      return _cachedStatistics!;
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to get statistics',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> _getUniquePagesCount() async {
    final result = await _db.rawQuery('''
      SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol}) as count
      FROM ${DbConstants.readingSessionsTable}
    ''');

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getPagesToday() async {
    final todayDateStr = DateQueryHelpers.today();

    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol}) as count
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} = ?
    ''',
      [todayDateStr],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getPagesThisWeek() async {
    final weekAgoDateStr = DateQueryHelpers.lastWeekStart();

    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol}) as count
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
    ''',
      [weekAgoDateStr],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getPagesThisMonth() async {
    final monthStartDateStr = DateQueryHelpers.thisMonthStart();

    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol}) as count
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
    ''',
      [monthStartDateStr],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getDaysThisWeek() async {
    final weekAgoDateStr = DateQueryHelpers.lastWeekStart();

    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ${DbConstants.sessionDateCol}) as count
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
    ''',
      [weekAgoDateStr],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getDaysThisMonth() async {
    final monthStartDateStr = DateQueryHelpers.thisMonthStart();

    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ${DbConstants.sessionDateCol}) as count
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
    ''',
      [monthStartDateStr],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getTotalReadingDays() async {
    final result = await _db.rawQuery('''
      SELECT COUNT(DISTINCT ${DbConstants.sessionDateCol}) as count
      FROM ${DbConstants.readingSessionsTable}
    ''');

    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<int> getCurrentStreak() async {
    await _ensureInitialized();

    // Check today first - must have read today to have a streak
    final todayDateStr = DateQueryHelpers.today();
    final todayResult = await _db.query(
      DbConstants.readingSessionsTable,
      columns: [DbConstants.pageNumberCol],
      where: '${DbConstants.sessionDateCol} = ?',
      whereArgs: [todayDateStr],
      limit: QueryLimits.singleResult,
    );

    if (todayResult.isEmpty) return 0; // No reading today = no streak

    // Count consecutive days backwards from today
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final dateStr = DateHelpers.formatDateForDb(checkDate);
      final result = await _db.query(
        DbConstants.readingSessionsTable,
        columns: [DbConstants.pageNumberCol],
        where: '${DbConstants.sessionDateCol} = ?',
        whereArgs: [dateStr],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) break; // Found a day with no reading

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      // Safety limit (prevent infinite loop)
      if (streak > QueryLimits.maxStreakDays) break;
    }

    return streak;
  }

  Future<int> _calculateLongestStreak() async {
    // Get all distinct dates sorted
    final dateResults = await _db.rawQuery('''
      SELECT DISTINCT ${DbConstants.sessionDateCol}
      FROM ${DbConstants.readingSessionsTable}
      ORDER BY ${DbConstants.sessionDateCol} ASC
    ''');

    if (dateResults.isEmpty) return 0;

    // Convert to DateTime list
    final dates = dateResults
        .map((row) => DateTime.parse(row[DbConstants.sessionDateCol] as String))
        .toList();

    int longestStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final daysDifference = dates[i].difference(dates[i - 1]).inDays;
      if (daysDifference == 1) {
        // Consecutive day
        currentStreak++;
      } else {
        // Gap found, reset streak
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }

    // Check final streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return longestStreak;
  }

  Future<int> _calculateCurrentStreak() async {
    return getCurrentStreak();
  }

  @override
  Future<int> getPagesReadToday() async {
    await _ensureInitialized();
    return _getPagesToday();
  }

  @override
  Future<List<int>> getPagesReadByDate(DateTime date) async {
    await _ensureInitialized();

    final dateStr = DateHelpers.formatDateForDb(date);

    final results = await _db.query(
      DbConstants.readingSessionsTable,
      columns: [DbConstants.pageNumberCol],
      where: '${DbConstants.sessionDateCol} = ?',
      whereArgs: [dateStr],
    );

    return results
        .map((row) => row[DbConstants.pageNumberCol] as int)
        .toSet()
        .toList(); // Return unique page numbers
  }

  @override
  Future<Map<DateTime, int>> getWeeklyProgress() async {
    await _ensureInitialized();

    final weekAgoDateStr = DateQueryHelpers.lastWeekStart();

    final results = await _db.rawQuery(
      '''
      SELECT
        ${DbConstants.sessionDateCol},
        COUNT(DISTINCT ${DbConstants.pageNumberCol}) as pages
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
      GROUP BY ${DbConstants.sessionDateCol}
      ORDER BY ${DbConstants.sessionDateCol} ASC
    ''',
      [weekAgoDateStr],
    );

    final Map<DateTime, int> progress = {};
    for (final row in results) {
      final dateStr = row[DbConstants.sessionDateCol] as String;
      final pages = row['pages'] as int? ?? 0;
      progress[DateTime.parse(dateStr)] = pages;
    }

    return progress;
  }

  @override
  Future<Map<DateTime, int>> getMonthlyProgress() async {
    await _ensureInitialized();

    final monthStartDateStr = DateQueryHelpers.thisMonthStart();

    final results = await _db.rawQuery(
      '''
      SELECT
        ${DbConstants.sessionDateCol},
        COUNT(DISTINCT ${DbConstants.pageNumberCol}) as pages
      FROM ${DbConstants.readingSessionsTable}
      WHERE ${DbConstants.sessionDateCol} >= ?
      GROUP BY ${DbConstants.sessionDateCol}
      ORDER BY ${DbConstants.sessionDateCol} ASC
    ''',
      [monthStartDateStr],
    );

    final Map<DateTime, int> progress = {};
    for (final row in results) {
      final dateStr = row[DbConstants.sessionDateCol] as String;
      final pages = row['pages'] as int? ?? 0;
      progress[DateTime.parse(dateStr)] = pages;
    }

    return progress;
  }

  @override
  Future<void> clearAllData() async {
    await _ensureInitialized();

    try {
      await _db.delete(DbConstants.readingSessionsTable);
      _cachedStatistics = null;
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to clear reading progress data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
