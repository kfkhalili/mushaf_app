import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../utils/initialization_mixin.dart';

/// WHY: Unified database service for all user-generated data.
/// Consolidates bookmarks, reading progress, memorization sessions, and preferences
/// into a single SQLite database for easier maintenance and backup.
class AppDataService with InitializationMixin {
  Database? _db;

  /// WHY: Ensures database is initialized. Uses mixin pattern to prevent
  /// concurrent initialization attempts.
  @override
  Future<void> ensureInitialized() async {
    if (isInitialized && _db != null) return;
    await super.ensureInitialized();
  }

  @override
  Future<void> doInit() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'app_data.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      singleInstance: true, // WHY: Ensures only one database connection exists
      // This prevents concurrent access issues and database locking
      onCreate: (db, version) async {
        // WHY: onCreate is already executed in a transaction by sqflite
        // Create all tables for unified storage
        await _createMemorizationSessionsTable(db);
        await _createBookmarksTable(db);
        await _createReadingSessionsTable(db);
        await _createUserPreferencesTable(db);

        // Create indexes for performance
        await _createIndexes(db);
      },
    );

    // WHY: Configure database with timeout and WAL mode for better concurrency.
    // Wrap in try-catch because PRAGMA statements may throw exceptions on some platforms
    // even when they're not errors (particularly on iOS read-only databases).
    try {
      await _db!.execute('PRAGMA journal_mode=WAL'); // Enable WAL mode
      await _db!.execute(
        'PRAGMA busy_timeout=5000',
      ); // 5 second timeout for locks
    } catch (e) {
      // Ignore exceptions from PRAGMA statements on some platforms.
      // The database is still functional without these settings.
    }

    markInitialized();
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
  /// Ensures all pending operations complete before closing.
  Future<void> close() async {
    if (_db != null) {
      // WHY: Ensure all pending transactions are committed before closing
      await _db!.close();
      _db = null;
    }
    resetInitializationState();
  }

  /// WHY: Executes a function within a database transaction.
  /// Provides automatic rollback on error and better performance for multi-step operations.
  /// Returns the result of the transaction function.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    await ensureInitialized();
    return _db!.transaction(action);
  }

  /// WHY: Executes multiple database operations in a batch.
  /// More efficient than individual operations when doing multiple inserts/updates.
  Future<void> batch(void Function(Batch batch) operations) async {
    await ensureInitialized();
    final batch = _db!.batch();
    operations(batch);
    await batch.commit();
  }
}
