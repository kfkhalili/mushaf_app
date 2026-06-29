import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/validation_helpers.dart';
import 'database_service.dart';
import 'app_data_service.dart';

abstract class BookmarksService {
  // Add bookmark by surah:ayah
  Future<void> addBookmark(int surahNumber, int ayahNumber);

  // Remove bookmark by surah:ayah
  Future<void> removeBookmark(int surahNumber, int ayahNumber);

  // Check if specific ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber);

  // Get all bookmarks (sorted by creation date)
  // [includeAyahText] - If true, fetches ayah text (requires DatabaseService).
  //                    Defaults to false for better separation of concerns.
  Future<List<Bookmark>> getAllBookmarks({
    bool newestFirst = true,
    bool includeAyahText = false,
  });

  // Get bookmark by surah:ayah
  Future<Bookmark?> getBookmarkByAyah(int surahNumber, int ayahNumber);

  // Clear all bookmarks
  Future<void> clearAllBookmarks();

  // Migration: Convert page-based bookmark to ayah-based
  Future<void> migratePageBookmark(int pageNumber);
}

/// WHY: Stores bookmarks in the unified app_data.db. Initialization and any
/// legacy-data migration are owned by [AppDataService]; this service simply
/// awaits `ensureInitialized()` before each operation.
class SqliteBookmarksService implements BookmarksService {
  final AppDataService _appDataService;
  final DatabaseService _databaseService;

  SqliteBookmarksService(this._appDataService, this._databaseService);

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

    await _appDataService.ensureInitialized();

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
        debugPrint('Could not cache page number for bookmark: $e');
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
    await _appDataService.ensureInitialized();

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
    await _appDataService.ensureInitialized();

    try {
      final result = await _db.query(
        DbConstants.bookmarksTable,
        columns: [DbConstants.idCol],
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: QueryLimits.singleResult,
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
  Future<List<Bookmark>> getAllBookmarks({
    bool newestFirst = true,
    bool includeAyahText = false,
  }) async {
    await _appDataService.ensureInitialized();

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

      // WHY: Only fetch ayah text when explicitly requested by UI layer.
      // This maintains separation of concerns - BookmarksService handles
      // bookmark data, DatabaseService handles ayah text.
      final Map<String, String> ayahTextsMap = <String, String>{};
      if (includeAyahText) {
        // Collect all surah:ayah pairs for bulk fetching
        // Use nullable casts and validate before use
        // WHY: Type safety - database data may be corrupted
        final ayahs = results
            .map((row) {
              final int? surahNumber = row[DbConstants.surahNumberCol] as int?;
              final int? ayahNumber = row[DbConstants.ayahNumberCol] as int?;
              if (surahNumber == null || ayahNumber == null) {
                return null; // Skip invalid entries
              }
              // Validate parsed surah/ayah numbers
              // WHY: Defense in depth - validate even trusted database data
              try {
                validateSurahNumber(surahNumber);
                validateAyahNumber(ayahNumber);
                return (surahNumber: surahNumber, ayahNumber: ayahNumber);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint(
                    'Invalid surah/ayah in bookmark: $surahNumber:$ayahNumber',
                  );
                }
                return null; // Skip invalid entries
              }
            })
            .whereType<(int surahNumber, int ayahNumber)>()
            .map((record) => (surahNumber: record.$1, ayahNumber: record.$2))
            .toList();

        // WHY: Bulk fetch all ayah texts in a single query instead of N queries
        ayahTextsMap.addAll(await _databaseService.getAyahTextsBulk(ayahs));
      }

      // Build bookmarks with optional pre-fetched ayah texts
      final bookmarks = <Bookmark>[];
      for (final row in results) {
        // Use nullable casts and check for null
        // WHY: Type safety - database data may be corrupted
        final int? surahNumberNullable =
            row[DbConstants.surahNumberCol] as int?;
        final int? ayahNumberNullable = row[DbConstants.ayahNumberCol] as int?;
        final int? idNullable = row[DbConstants.idCol] as int?;
        final String? createdAtStr = row[DbConstants.createdAtCol] as String?;

        if (surahNumberNullable == null ||
            ayahNumberNullable == null ||
            idNullable == null ||
            createdAtStr == null) {
          if (kDebugMode) {
            debugPrint('Missing required fields in bookmark data');
          }
          continue; // Skip invalid entries
        }

        // Validate parsed surah/ayah numbers
        // WHY: Defense in depth - validate even trusted database data
        try {
          validateSurahNumber(surahNumberNullable);
          validateAyahNumber(ayahNumberNullable);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              'Invalid surah/ayah in bookmark: $surahNumberNullable:$ayahNumberNullable',
            );
          }
          continue; // Skip invalid entries
        }

        final int surahNumber = surahNumberNullable;
        final int ayahNumber = ayahNumberNullable;
        final int id = idNullable;
        final verseKey = '$surahNumber:$ayahNumber';

        // Parse DateTime safely with exception handling
        // WHY: Corrupted database data may contain invalid date formats
        DateTime createdAt;
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Invalid date format in bookmark: $createdAtStr');
          }
          // Use current date as safe default
          createdAt = DateTime.now();
        }

        bookmarks.add(
          Bookmark(
            id: id,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            cachedPageNumber: row[DbConstants.cachedPageNumberCol] as int?,
            createdAt: createdAt,
            note: row[DbConstants.noteCol] as String?,
            ayahText: includeAyahText ? (ayahTextsMap[verseKey] ?? '') : null,
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
    await _appDataService.ensureInitialized();

    try {
      final results = await _db.query(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: QueryLimits.singleResult,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      // Use nullable casts and check for null
      // WHY: Type safety - database data may be corrupted
      final int? idNullable = row[DbConstants.idCol] as int?;
      final int? surahNumberNullable = row[DbConstants.surahNumberCol] as int?;
      final int? ayahNumberNullable = row[DbConstants.ayahNumberCol] as int?;
      final String? createdAtStr = row[DbConstants.createdAtCol] as String?;

      if (idNullable == null ||
          surahNumberNullable == null ||
          ayahNumberNullable == null ||
          createdAtStr == null) {
        if (kDebugMode) {
          debugPrint('Missing required fields in bookmark data');
        }
        return null; // Safe default
      }

      // Validate parsed surah/ayah numbers
      // WHY: Defense in depth - validate even trusted database data
      try {
        validateSurahNumber(surahNumberNullable);
        validateAyahNumber(ayahNumberNullable);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'Invalid surah/ayah in bookmark: $surahNumberNullable:$ayahNumberNullable',
          );
        }
        return null; // Safe default
      }

      final ayahText = await _databaseService.getAyahText(
        surahNumberNullable,
        ayahNumberNullable,
      );

      // Parse DateTime safely with exception handling
      // WHY: Corrupted database data may contain invalid date formats
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Invalid date format in bookmark: $createdAtStr');
        }
        // Use current date as safe default
        createdAt = DateTime.now();
      }

      return Bookmark(
        id: idNullable,
        surahNumber: surahNumberNullable,
        ayahNumber: ayahNumberNullable,
        cachedPageNumber: row[DbConstants.cachedPageNumberCol] as int?,
        createdAt: createdAt,
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
    await _appDataService.ensureInitialized();

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
    await _appDataService.ensureInitialized();

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
