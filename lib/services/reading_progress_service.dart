import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';

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

class SqliteReadingProgressService implements ReadingProgressService {
  Database? _db;
  bool _initialized = false;
  ReadingStatistics? _cachedStatistics;

  Future<void> _ensureInitialized() async {
    if (_initialized && _db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'reading_progress.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DbConstants.readingSessionsTable} (
            ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DbConstants.sessionDateCol} TEXT NOT NULL,
            ${DbConstants.pageNumberCol} INTEGER NOT NULL,
            ${DbConstants.timestampCol} TEXT NOT NULL,
            ${DbConstants.durationSecondsCol} INTEGER
          )
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_reading_sessions_date
          ON ${DbConstants.readingSessionsTable}(${DbConstants.sessionDateCol} DESC)
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_reading_sessions_page
          ON ${DbConstants.readingSessionsTable}(${DbConstants.pageNumberCol})
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_reading_sessions_timestamp
          ON ${DbConstants.readingSessionsTable}(${DbConstants.timestampCol} DESC)
        ''');
      },
    );

    _initialized = true;
  }

  @override
  Future<void> recordPageView(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPages) {
      throw ArgumentError('Page number must be between 1 and $totalPages');
    }

    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now();
    final sessionDate = DateTime(now.year, now.month, now.day);

    try {
      await _db!.insert(DbConstants.readingSessionsTable, {
        DbConstants.sessionDateCol: sessionDate.toIso8601String().split('T')[0],
        DbConstants.pageNumberCol: pageNumber,
        DbConstants.timestampCol: now.toIso8601String(),
      });

      // Invalidate statistics cache
      _cachedStatistics = null;
    } catch (e) {
      throw Exception('Failed to record page view: $e');
    }
  }

  @override
  Future<ReadingStatistics> getStatistics() async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

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
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  Future<int> _getUniquePagesCount() async {
    if (_db == null) throw StateError('Database not initialized');

    final result = await _db!.rawQuery('''
      SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol}) as count
      FROM ${DbConstants.readingSessionsTable}
    ''');

    return result.first['count'] as int? ?? 0;
  }

  Future<int> _getPagesToday() async {
    if (_db == null) throw StateError('Database not initialized');

    final todayDateStr = DateTime.now().toIso8601String().split('T')[0];

    final result = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekAgoDateStr = weekAgo.toIso8601String().split('T')[0];

    final result = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartDateStr = monthStart.toIso8601String().split('T')[0];

    final result = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekAgoDateStr = weekAgo.toIso8601String().split('T')[0];

    final result = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartDateStr = monthStart.toIso8601String().split('T')[0];

    final result = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final result = await _db!.rawQuery('''
      SELECT COUNT(DISTINCT ${DbConstants.sessionDateCol}) as count
      FROM ${DbConstants.readingSessionsTable}
    ''');

    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<int> getCurrentStreak() async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    // Check today first - must have read today to have a streak
    final todayDateStr = DateTime.now().toIso8601String().split('T')[0];
    final todayResult = await _db!.query(
      DbConstants.readingSessionsTable,
      columns: [DbConstants.pageNumberCol],
      where: '${DbConstants.sessionDateCol} = ?',
      whereArgs: [todayDateStr],
      limit: 1,
    );

    if (todayResult.isEmpty) return 0; // No reading today = no streak

    // Count consecutive days backwards from today
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      final result = await _db!.query(
        DbConstants.readingSessionsTable,
        columns: [DbConstants.pageNumberCol],
        where: '${DbConstants.sessionDateCol} = ?',
        whereArgs: [dateStr],
        limit: 1,
      );

      if (result.isEmpty) break; // Found a day with no reading

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      // Safety limit (prevent infinite loop)
      if (streak > 365) break;
    }

    return streak;
  }

  Future<int> _calculateLongestStreak() async {
    if (_db == null) throw StateError('Database not initialized');

    // Get all distinct dates sorted
    final dateResults = await _db!.rawQuery('''
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
    if (_db == null) throw StateError('Database not initialized');

    final dateStr = date.toIso8601String().split('T')[0];

    final results = await _db!.query(
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
    if (_db == null) throw StateError('Database not initialized');

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekAgoDateStr = weekAgo.toIso8601String().split('T')[0];

    final results = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartDateStr = monthStart.toIso8601String().split('T')[0];

    final results = await _db!.rawQuery(
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
    if (_db == null) throw StateError('Database not initialized');

    try {
      await _db!.delete(DbConstants.readingSessionsTable);
      _cachedStatistics = null;
    } catch (e) {
      throw Exception('Failed to clear reading progress data: $e');
    }
  }
}
