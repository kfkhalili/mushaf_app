import 'package:flutter/foundation.dart';

import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import 'database_service.dart';
import 'app_data_service.dart';
import 'migration_service.dart';

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

  // Clear all bookmarks
  Future<void> clearAllBookmarks();

  // Migration: Convert page-based bookmark to ayah-based
  Future<void> migratePageBookmark(int pageNumber);
}

/// WHY: Updated to use unified app_data.db instead of separate bookmarks.db.
/// Migrates data from old database on first use.
class SqliteBookmarksService implements BookmarksService {
  final AppDataService _appDataService;
  final DatabaseService _databaseService;
  final MigrationService _migrationService;
  bool _initialized = false;

  SqliteBookmarksService(this._appDataService, this._databaseService)
    : _migrationService = MigrationService(_appDataService);

  /// WHY: Ensures unified database is initialized and runs migration if needed.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // WHY: Initialize unified database (creates app_data.db if needed)
    await _appDataService.ensureInitialized();

    // WHY: Run migration from old bookmarks.db if needed
    await _migrationService.migrateIfNeeded();

    _initialized = true;
  }

  /// WHY: Getter for database instance from unified service.
  Database get _db => _appDataService.database;

  @override
  Future<void> addBookmark(int surahNumber, int ayahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError('Surah number must be between 1 and 114');
    }
    if (ayahNumber < 1) {
      throw ArgumentError('Ayah number must be greater than 0');
    }

    await _ensureInitialized();

    final now = DateTime.now().toIso8601String();

    // Optionally calculate cached page number for current layout
    int? cachedPageNumber;
    try {
      cachedPageNumber = await _databaseService.getPageForAyah(
        surahNumber,
        ayahNumber,
      );
    } catch (e) {
      // If page lookup fails, continue without cached page number
      if (kDebugMode) {
        print('Could not cache page number for bookmark: $e');
      }
    }

    try {
      await _db.insert(DbConstants.bookmarksTable, {
        DbConstants.surahNumberCol: surahNumber,
        DbConstants.ayahNumberCol: ayahNumber,
        DbConstants.cachedPageNumberCol: cachedPageNumber,
        DbConstants.createdAtCol: now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to add bookmark',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();

    try {
      await _db.delete(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
      );
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to remove bookmark',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();

    try {
      final result = await _db.query(
        DbConstants.bookmarksTable,
        columns: [DbConstants.idCol],
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to check bookmark status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true}) async {
    await _ensureInitialized();

    try {
      final results = await _db.query(
        DbConstants.bookmarksTable,
        orderBy: newestFirst
            ? '${DbConstants.createdAtCol} DESC'
            : '${DbConstants.createdAtCol} ASC',
      );

      if (results.isEmpty) {
        return [];
      }

      // Collect all surah:ayah pairs for bulk fetching
      final ayahs = results
          .map(
            (row) => (
              surahNumber: row[DbConstants.surahNumberCol] as int,
              ayahNumber: row[DbConstants.ayahNumberCol] as int,
            ),
          )
          .toList();

      // WHY: Bulk fetch all ayah texts in a single query instead of N queries
      final ayahTextsMap = await _databaseService.getAyahTextsBulk(ayahs);

      // Build bookmarks with pre-fetched ayah texts
      final bookmarks = <Bookmark>[];
      for (final row in results) {
        final surahNumber = row[DbConstants.surahNumberCol] as int;
        final ayahNumber = row[DbConstants.ayahNumberCol] as int;
        final verseKey = '$surahNumber:$ayahNumber';

        bookmarks.add(
          Bookmark(
            id: row[DbConstants.idCol] as int,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            cachedPageNumber: row[DbConstants.cachedPageNumberCol] as int?,
            createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
            note: row[DbConstants.noteCol] as String?,
            ayahText: ayahTextsMap[verseKey] ?? '',
          ),
        );
      }
      return bookmarks;
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to get bookmarks',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Bookmark?> getBookmarkByAyah(int surahNumber, int ayahNumber) async {
    await _ensureInitialized();

    try {
      final results = await _db.query(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      final ayahText = await _databaseService.getAyahText(
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
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to get bookmark by ayah',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllBookmarks() async {
    await _ensureInitialized();

    try {
      await _db.delete(DbConstants.bookmarksTable);
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to clear bookmarks',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> migratePageBookmark(int pageNumber) async {
    // Migration: Convert page-based bookmark to ayah-based
    // This method is called for old bookmarks that need migration
    await _ensureInitialized();

    try {
      final firstAyah = await _databaseService.getFirstAyahOnPage(pageNumber);
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
    } catch (e, stackTrace) {
      throw DatabaseOperationException(
        'Failed to migrate page bookmark',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
