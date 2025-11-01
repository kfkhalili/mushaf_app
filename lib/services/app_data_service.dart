import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';

/// WHY: Unified database service for all user-generated data.
/// Consolidates bookmarks, reading progress, memorization sessions, and preferences
/// into a single SQLite database for easier maintenance and backup.
class AppDataService {
  Database? _db;
  bool _initialized = false;
  Future<void>? _initFuture;

  /// WHY: Ensures database is initialized. Uses _initFuture pattern to prevent
  /// concurrent initialization attempts.
  Future<void> ensureInitialized() async {
    if (_initialized && _db != null) return;
    _initFuture ??= _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'app_data.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create all tables for unified storage
        await _createMemorizationSessionsTable(db);
        await _createBookmarksTable(db);
        await _createReadingSessionsTable(db);
        await _createUserPreferencesTable(db);

        // Create indexes for performance
        await _createIndexes(db);
      },
    );

    _initialized = true;
  }

  /// WHY: Creates memorization_sessions table for persistent storage
  /// of memorization progress (migrated from in-memory storage).
  Future<void> _createMemorizationSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.memorizationSessionsTable} (
        ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.pageNumberCol} INTEGER NOT NULL,
        ${DbConstants.firstAyahIndexCol} INTEGER NOT NULL,
        ${DbConstants.lastAyahIndexShownCol} INTEGER NOT NULL,
        ${DbConstants.passCountCol} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.windowDataCol} TEXT NOT NULL,
        ${DbConstants.lastUpdatedAtCol} TEXT NOT NULL,
        ${DbConstants.createdAtCol} TEXT NOT NULL,
        UNIQUE(${DbConstants.pageNumberCol})
      )
    ''');
  }

  /// WHY: Creates bookmarks table (will be migrated from bookmarks.db).
  Future<void> _createBookmarksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.bookmarksTable} (
        ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.surahNumberCol} INTEGER NOT NULL,
        ${DbConstants.ayahNumberCol} INTEGER NOT NULL,
        ${DbConstants.cachedPageNumberCol} INTEGER,
        ${DbConstants.createdAtCol} TEXT NOT NULL,
        ${DbConstants.noteCol} TEXT,
        UNIQUE(${DbConstants.surahNumberCol}, ${DbConstants.ayahNumberCol})
      )
    ''');
  }

  /// WHY: Creates reading_sessions table (will be migrated from reading_progress.db).
  Future<void> _createReadingSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.readingSessionsTable} (
        ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.sessionDateCol} TEXT NOT NULL,
        ${DbConstants.pageNumberCol} INTEGER NOT NULL,
        ${DbConstants.timestampCol} TEXT NOT NULL,
        ${DbConstants.durationSecondsCol} INTEGER
      )
    ''');
  }

  /// WHY: Creates user_preferences table for app-level preferences
  /// that need persistence (future use).
  Future<void> _createUserPreferencesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.userPreferencesTable} (
        ${DbConstants.keyCol} TEXT PRIMARY KEY,
        ${DbConstants.valueCol} TEXT NOT NULL,
        ${DbConstants.updatedAtCol} TEXT NOT NULL
      )
    ''');
  }

  /// WHY: Creates indexes for efficient queries.
  Future<void> _createIndexes(Database db) async {
    // Memorization sessions indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memorization_sessions_page
      ON ${DbConstants.memorizationSessionsTable}(${DbConstants.pageNumberCol})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_memorization_sessions_updated
      ON ${DbConstants.memorizationSessionsTable}(${DbConstants.lastUpdatedAtCol} DESC)
    ''');

    // Bookmarks indexes (same as before)
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bookmarks_surah_ayah
      ON ${DbConstants.bookmarksTable}(${DbConstants.surahNumberCol}, ${DbConstants.ayahNumberCol})
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
      ON ${DbConstants.bookmarksTable}(${DbConstants.createdAtCol} DESC)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bookmarks_page_number
      ON ${DbConstants.bookmarksTable}(${DbConstants.cachedPageNumberCol})
    ''');

    // Reading sessions indexes (same as before)
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
  }

  /// WHY: Getter for database instance. Throws if not initialized.
  Database get database {
    if (_db == null) throw StateError('Database not initialized');
    return _db!;
  }

  /// WHY: Closes database connection. Used for cleanup.
  Future<void> close() async {
    await _db?.close();
    _initialized = false;
    _initFuture = null;
  }
}
