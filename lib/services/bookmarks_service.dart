import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import 'database_service.dart';

abstract class BookmarksService {
  // Add bookmark by surah:ayah
  Future<void> addBookmark(int surahNumber, int ayahNumber);

  // Remove bookmark by surah:ayah
  Future<void> removeBookmark(int surahNumber, int ayahNumber);

  // Check if specific ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber);

  // Get all bookmarks (sorted by creation date)
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true});

  // Get bookmark by surah:ayah
  Future<Bookmark?> getBookmarkByAyah(int surahNumber, int ayahNumber);

  // Helper: Check if any ayah on a page is bookmarked (for UI status)
  Future<bool> isPageBookmarked(int pageNumber);

  // Clear all bookmarks
  Future<void> clearAllBookmarks();

  // Migration: Convert page-based bookmark to ayah-based
  Future<void> migratePageBookmark(int pageNumber);
}

class SqliteBookmarksService implements BookmarksService {
  Database? _db;
  bool _initialized = false;
  DatabaseService? _databaseService;

  Future<void> _ensureInitialized() async {
    if (_initialized && _db != null) {
      // Check if migration is needed even if initialized
      await _checkAndRunMigration();
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'bookmarks.db');

    _db = await openDatabase(
      dbPath,
      version: 3, // Increment version to force recreation
      onCreate: (db, version) async {
        // Create new schema with ayah-based columns
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Recreate table with ayah-based schema for any version < 3
        if (oldVersion < 3) {
          await db.execute(
            'DROP TABLE IF EXISTS ${DbConstants.bookmarksTable}',
          );
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
        }
      },
    );

    // Check if migration is needed (table might exist with old schema)
    await _checkAndRunMigration();

    _initialized = true;
  }

  /// Check if migration is needed and recreate table with correct schema
  Future<void> _checkAndRunMigration() async {
    if (_db == null) return;

    try {
      final tableInfo = await _db!.rawQuery(
        "PRAGMA table_info(${DbConstants.bookmarksTable})",
      );
      final hasSurahNumber = tableInfo.any(
        (col) => col['name'] == DbConstants.surahNumberCol,
      );
      final hasPageNumber = tableInfo.any(
        (col) => col['name'] == DbConstants.pageNumberCol,
      );

      // If table has old schema (has page_number but not surah_number), recreate
      if (hasPageNumber && !hasSurahNumber) {
        // Drop old table and recreate with new schema
        await _db!.execute(
          'DROP TABLE IF EXISTS ${DbConstants.bookmarksTable}',
        );

        // Create new table with ayah-based schema
        await _db!.execute('''
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

        // Create indexes
        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_surah_ayah
          ON ${DbConstants.bookmarksTable}(${DbConstants.surahNumberCol}, ${DbConstants.ayahNumberCol})
        ''');

        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
          ON ${DbConstants.bookmarksTable}(${DbConstants.createdAtCol} DESC)
        ''');

        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_page_number
          ON ${DbConstants.bookmarksTable}(${DbConstants.cachedPageNumberCol})
        ''');
      }
    } catch (e) {
      // Table might not exist yet or error, recreate it
      try {
        await _db!.execute(
          'DROP TABLE IF EXISTS ${DbConstants.bookmarksTable}',
        );
        await _db!.execute('''
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

        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_surah_ayah
          ON ${DbConstants.bookmarksTable}(${DbConstants.surahNumberCol}, ${DbConstants.ayahNumberCol})
        ''');

        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
          ON ${DbConstants.bookmarksTable}(${DbConstants.createdAtCol} DESC)
        ''');

        await _db!.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_page_number
          ON ${DbConstants.bookmarksTable}(${DbConstants.cachedPageNumberCol})
        ''');
      } catch (recreateError) {
        print('Error recreating bookmarks table: $recreateError');
      }
    }
  }

  @override
  Future<void> addBookmark(int surahNumber, int ayahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError('Surah number must be between 1 and 114');
    }
    if (ayahNumber < 1) {
      throw ArgumentError('Ayah number must be greater than 0');
    }

    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now().toIso8601String();

    // Optionally calculate cached page number for current layout
    int? cachedPageNumber;
    try {
      if (_databaseService == null) {
        _databaseService = DatabaseService();
        await _databaseService!.init();
      }
      cachedPageNumber = await _databaseService!.getPageForAyah(
        surahNumber,
        ayahNumber,
      );
    } catch (e) {
      // If page lookup fails, continue without cached page number
      print('Could not cache page number for bookmark: $e');
    }

    try {
      await _db!.insert(DbConstants.bookmarksTable, {
        DbConstants.surahNumberCol: surahNumber,
        DbConstants.ayahNumberCol: ayahNumber,
        DbConstants.cachedPageNumberCol: cachedPageNumber,
        DbConstants.createdAtCol: now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      await _db!.delete(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
      );
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      final result = await _db!.query(
        DbConstants.bookmarksTable,
        columns: [DbConstants.idCol],
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check bookmark status: $e');
    }
  }

  @override
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true}) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      if (_databaseService == null) {
        _databaseService = DatabaseService();
        await _databaseService!.init();
      }

      final results = await _db!.query(
        DbConstants.bookmarksTable,
        orderBy: newestFirst
            ? '${DbConstants.createdAtCol} DESC'
            : '${DbConstants.createdAtCol} ASC',
      );

      final bookmarks = <Bookmark>[];
      for (final row in results) {
        final surahNumber = row[DbConstants.surahNumberCol] as int;
        final ayahNumber = row[DbConstants.ayahNumberCol] as int;

        final ayahText = await _databaseService!.getAyahText(
          surahNumber,
          ayahNumber,
        );

        bookmarks.add(
          Bookmark(
            id: row[DbConstants.idCol] as int,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            cachedPageNumber: row[DbConstants.cachedPageNumberCol] as int?,
            createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
            note: row[DbConstants.noteCol] as String?,
            ayahText: ayahText,
          ),
        );
      }
      return bookmarks;
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  @override
  Future<Bookmark?> getBookmarkByAyah(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      final results = await _db!.query(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final row = results.first;

      if (_databaseService == null) {
        _databaseService = DatabaseService();
        await _databaseService!.init();
      }

      final ayahText = await _databaseService!.getAyahText(
        surahNumber,
        ayahNumber,
      );

      return Bookmark(
        id: row[DbConstants.idCol] as int,
        surahNumber: row[DbConstants.surahNumberCol] as int,
        ayahNumber: row[DbConstants.ayahNumberCol] as int,
        cachedPageNumber: row[DbConstants.cachedPageNumberCol] as int?,
        createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
        note: row[DbConstants.noteCol] as String?,
        ayahText: ayahText,
      );
    } catch (e) {
      throw Exception('Failed to get bookmark by ayah: $e');
    }
  }

  @override
  Future<bool> isPageBookmarked(int pageNumber) async {
    // Helper method: Check if any ayah on a page is bookmarked
    // Gets first ayah on page and checks if it's bookmarked
    try {
      if (_databaseService == null) {
        _databaseService = DatabaseService();
        await _databaseService!.init();
      }
      final firstAyah = await _databaseService!.getFirstAyahOnPage(pageNumber);
      final surah = firstAyah['surah']!;
      final ayah = firstAyah['ayah']!;
      return await isBookmarked(surah, ayah);
    } catch (e) {
      // If we can't determine the ayah, return false
      return false;
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      await _db!.delete(DbConstants.bookmarksTable);
    } catch (e) {
      throw Exception('Failed to clear bookmarks: $e');
    }
  }

  @override
  Future<void> migratePageBookmark(int pageNumber) async {
    // Migration: Convert page-based bookmark to ayah-based
    // This method is called for old bookmarks that need migration
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      if (_databaseService == null) {
        _databaseService = DatabaseService();
        await _databaseService!.init();
      }
      final firstAyah = await _databaseService!.getFirstAyahOnPage(pageNumber);
      final surah = firstAyah['surah']!;
      final ayah = firstAyah['ayah']!;

      // Check if this ayah is already bookmarked
      final existing = await getBookmarkByAyah(surah, ayah);
      if (existing != null) {
        // Already migrated
        return;
      }

      // Create new bookmark with ayah data
      await addBookmark(surah, ayah);
    } catch (e) {
      throw Exception('Failed to migrate page bookmark: $e');
    }
  }
}
