import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';

abstract class BookmarksService {
  Future<void> addBookmark(int pageNumber);
  Future<void> removeBookmark(int pageNumber);
  Future<bool> isBookmarked(int pageNumber);
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true});
  Future<Bookmark?> getBookmarkByPage(int pageNumber);
  Future<void> clearAllBookmarks();
}

class SqliteBookmarksService implements BookmarksService {
  Database? _db;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized && _db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'bookmarks.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DbConstants.bookmarksTable} (
            ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DbConstants.pageNumberCol} INTEGER NOT NULL UNIQUE,
            ${DbConstants.createdAtCol} TEXT NOT NULL,
            ${DbConstants.noteCol} TEXT
          )
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_page_number
          ON ${DbConstants.bookmarksTable}(${DbConstants.pageNumberCol})
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
          ON ${DbConstants.bookmarksTable}(${DbConstants.createdAtCol} DESC)
        ''');
      },
    );

    _initialized = true;
  }

  @override
  Future<void> addBookmark(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPages) {
      throw ArgumentError('Page number must be between 1 and $totalPages');
    }

    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now().toIso8601String();

    try {
      await _db!.insert(
        DbConstants.bookmarksTable,
        {
          DbConstants.pageNumberCol: pageNumber,
          DbConstants.createdAtCol: now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> removeBookmark(int pageNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      await _db!.delete(
        DbConstants.bookmarksTable,
        where: '${DbConstants.pageNumberCol} = ?',
        whereArgs: [pageNumber],
      );
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  @override
  Future<bool> isBookmarked(int pageNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      final result = await _db!.query(
        DbConstants.bookmarksTable,
        columns: [DbConstants.idCol],
        where: '${DbConstants.pageNumberCol} = ?',
        whereArgs: [pageNumber],
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
      final results = await _db!.query(
        DbConstants.bookmarksTable,
        orderBy: newestFirst
            ? '${DbConstants.createdAtCol} DESC'
            : '${DbConstants.createdAtCol} ASC',
      );

      return results.map((row) {
        return Bookmark(
          id: row[DbConstants.idCol] as int,
          pageNumber: row[DbConstants.pageNumberCol] as int,
          createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
          note: row[DbConstants.noteCol] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  @override
  Future<Bookmark?> getBookmarkByPage(int pageNumber) async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    try {
      final results = await _db!.query(
        DbConstants.bookmarksTable,
        where: '${DbConstants.pageNumberCol} = ?',
        whereArgs: [pageNumber],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Bookmark(
        id: row[DbConstants.idCol] as int,
        pageNumber: row[DbConstants.pageNumberCol] as int,
        createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
        note: row[DbConstants.noteCol] as String?,
      );
    } catch (e) {
      throw Exception('Failed to get bookmark by page: $e');
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
}

