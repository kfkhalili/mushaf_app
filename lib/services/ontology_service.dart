import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/ontology_models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/validation_helpers.dart';

class OntologyService with InitializationMixin {
  Database? _topicsDb;

  @override
  Future<void> doInit() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      const dbAssetPath = 'assets/db';

      // Use existing _initDb pattern from DatabaseService
      _topicsDb = await _initDb(
        documentsDirectory,
        dbAssetPath,
        topicsDbFileName,
      );

      markInitialized();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OntologyService initialization failed: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  Future<void> close() async {
    await _topicsDb?.close();
    _topicsDb = null;
    resetInitializationState();
  }

  /// Initializes a database by copying from assets if not already present.
  /// WHY: Reuse pattern from DatabaseService for consistency.
  Future<Database> _initDb(
    Directory documentsDirectory,
    String assetPath,
    String assetFileName,
  ) async {
    final destinationPath = p.join(documentsDirectory.path, assetFileName);

    await _copyDatabaseIfNeeded(
      assetFileName: assetFileName,
      destinationPath: destinationPath,
    );

    try {
      final db = await openDatabase(
        destinationPath,
        readOnly: true,
        singleInstance: true,
      );

      // WHY: Don't set PRAGMA busy_timeout on read-only databases.
      // busy_timeout is for write locks and not needed for read-only databases.
      // On iOS (SqfliteDarwinDatabase), attempting PRAGMA on read-only databases
      // throws exceptions even though they're not errors. The database works
      // perfectly fine without this setting for read-only operations.

      return db;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error opening topics database: $e\n$stackTrace');
      }
      throw DatabaseConnectionException(
        "Error opening database '$assetFileName'",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Copies database from assets to documents directory if it doesn't exist.
  /// WHY: Reuse pattern from DatabaseService for consistency.
  Future<void> _copyDatabaseIfNeeded({
    required String assetFileName,
    required String destinationPath,
  }) async {
    // Validate database file name against whitelist
    final allowedDbNames = [topicsDbFileName];
    try {
      validateDatabaseFileName(assetFileName, allowedDbNames);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException("Invalid database file name: $e");
    }

    final dbFile = File(destinationPath);

    // Validate path to prevent path traversal
    final documentsDirectory = await getApplicationDocumentsDirectory();
    try {
      validateFilePath(destinationPath, documentsDirectory.path);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException("Path traversal detected: $e");
    }

    // WHY: Avoid recopying if the database already exists.
    if (await dbFile.exists()) {
      return;
    }
    try {
      if (kDebugMode) {
        debugPrint('Copying topics database from assets: $assetFileName');
      }
      // WHY: Load the database from assets and write it to the device's documents directory.
      final assetPath = p.join('assets/db', assetFileName);
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.parent.create(recursive: true); // Ensure directory exists
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error copying database: $e\n$stackTrace');
      }
      throw DatabaseConnectionException(
        "Error copying database '$assetFileName' from assets",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches a specific topic by its ID.
  Future<Topic> getTopicById(int topicId) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    final List<Map<String, dynamic>> result = await _topicsDb!.query(
      DbConstants.topicsTable,
      where: '${DbConstants.topicIdCol} = ?',
      whereArgs: [topicId.toString()],
      limit: QueryLimits.singleResult,
    );

    if (result.isEmpty) {
      throw DatabaseNotFoundException("Topic not found: $topicId");
    }

    return Topic.fromMap(result.first);
  }

  /// Fetches all topics related to a specific ayah.
  Future<List<Topic>> getTopicsForAyah(int surahNumber, int ayahNumber) async {
    // Validate input parameters
    validateSurahAyah(surahNumber, ayahNumber);

    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    // Check if TopicVerseMap table exists
    final tableCheck = await _topicsDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [DbConstants.topicVerseMapTable],
    );

    if (tableCheck.isNotEmpty) {
      // Use normalized table
      try {
        final List<Map<String, dynamic>> results = await _topicsDb!.rawQuery(
          '''
          SELECT t.* FROM ${DbConstants.topicsTable} t
          JOIN ${DbConstants.topicVerseMapTable} m ON t.${DbConstants.topicIdCol} = m.${DbConstants.topicIdCol}
          WHERE m.${DbConstants.surahNumberCol} = ? AND m.${DbConstants.ayahNumberCol} = ?
          ORDER BY t.${DbConstants.arabicNameCol} ASC
          ''',
          [surahNumber.toString(), ayahNumber.toString()],
        );
        return results.map((row) => Topic.fromMap(row)).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error querying TopicVerseMap: $e');
        }
        // Fall through to fallback
      }
    }

    // Fallback: Parse ayahs column (legacy schema)
    // Use LIKE query for better performance instead of loading all topics
    final verseKey = '$surahNumber:$ayahNumber';
    final versePattern = '%$verseKey%';
    try {
      // Use LIKE query to filter at database level instead of loading all rows
      final List<Map<String, dynamic>> results = await _topicsDb!.rawQuery(
        'SELECT * FROM ${DbConstants.topicsTable} WHERE ayahs LIKE ?',
        [versePattern], // Match verse key anywhere in ayahs string
      );

      // Filter to exact matches only (LIKE might match partials)
      final List<Topic> topics = [];
      for (final row in results) {
        final ayahsStr = row['ayahs'] as String?;
        if (ayahsStr != null && ayahsStr.isNotEmpty) {
          // Parse "2:85, 2:113, 3:55" format and check for exact match
          final ayahs = ayahsStr.split(',').map((a) => a.trim()).toList();
          if (ayahs.contains(verseKey)) {
            topics.add(Topic.fromMap(row));
          }
        }
      }

      return topics;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in getTopicsForAyah fallback: $e');
      }
      return [];
    }
  }

  /// Fetches all verse references for a specific topic.
  Future<List<VerseReference>> getVersesForTopic(int topicId) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    // Check if TopicVerseMap table exists
    final tableCheck = await _topicsDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [DbConstants.topicVerseMapTable],
    );

    if (tableCheck.isNotEmpty) {
      // Use normalized table
      try {
        final List<Map<String, dynamic>> results = await _topicsDb!.query(
          DbConstants.topicVerseMapTable,
          columns: [DbConstants.surahNumberCol, DbConstants.ayahNumberCol],
          where: '${DbConstants.topicIdCol} = ?',
          whereArgs: [topicId.toString()],
          orderBy:
              '${DbConstants.surahNumberCol} ASC, ${DbConstants.ayahNumberCol} ASC',
        );
        return results.map((row) => VerseReference.fromMap(row)).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error querying TopicVerseMap: $e');
        }
        // Fall through to fallback
      }
    }

    // Fallback: Parse ayahs column (legacy schema)
    try {
      final List<Map<String, dynamic>> result = await _topicsDb!.query(
        DbConstants.topicsTable,
        where: '${DbConstants.topicIdCol} = ?',
        whereArgs: [topicId.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) {
        return [];
      }

      final ayahsStr = result.first['ayahs'] as String?;
      if (ayahsStr == null || ayahsStr.isEmpty) {
        return [];
      }

      // Parse "2:85, 2:113, 3:55" format
      final List<VerseReference> verses = [];
      final ayahs = ayahsStr.split(',').map((a) => a.trim()).toList();
      for (final ayah in ayahs) {
        final parts = ayah.split(':');
        if (parts.length == 2) {
          final surah = int.tryParse(parts[0].trim());
          final ayahNum = int.tryParse(parts[1].trim());
          if (surah != null && ayahNum != null) {
            // Validate parsed surah/ayah numbers before use
            // WHY: Defense in depth - validate even trusted database data
            try {
              validateSurahNumber(surah);
              validateAyahNumber(ayahNum);
              verses.add(
                VerseReference(surahNumber: surah, ayahNumber: ayahNum),
              );
            } catch (e) {
              // Skip invalid entries - database data may be corrupted
              if (kDebugMode) {
                debugPrint('Invalid surah/ayah in database: $surah:$ayahNum');
              }
            }
          }
        }
      }

      return verses;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in getVersesForTopic fallback: $e');
      }
      return [];
    }
  }

  /// Fetches all topics marked as "related" to the given topic.
  Future<List<Topic>> getRelatedTopics(int sourceTopicId) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    // Check if RelatedTopicsMap table exists
    final tableCheck = await _topicsDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [DbConstants.relatedTopicsMapTable],
    );

    if (tableCheck.isNotEmpty) {
      // Use normalized table
      try {
        final List<Map<String, dynamic>> results = await _topicsDb!.rawQuery(
          '''
          SELECT t.* FROM ${DbConstants.topicsTable} t
          JOIN ${DbConstants.relatedTopicsMapTable} m ON t.${DbConstants.topicIdCol} = m.${DbConstants.relatedTopicIdCol}
          WHERE m.${DbConstants.sourceTopicIdCol} = ?
          ORDER BY t.${DbConstants.arabicNameCol} ASC
          ''',
          [sourceTopicId.toString()],
        );
        return results.map((row) => Topic.fromMap(row)).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error querying RelatedTopicsMap: $e');
        }
        // Fall through to fallback
      }
    }

    // Fallback: Parse related_topics column (legacy schema)
    try {
      final List<Map<String, dynamic>> result = await _topicsDb!.query(
        DbConstants.topicsTable,
        where: '${DbConstants.topicIdCol} = ?',
        whereArgs: [sourceTopicId.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) {
        return [];
      }

      final relatedTopicsStr = result.first['related_topics'] as String?;
      if (relatedTopicsStr == null || relatedTopicsStr.isEmpty) {
        return [];
      }

      // Parse "1, 5, 22" format
      final relatedIds = relatedTopicsStr
          .split(',')
          .map((id) => id.trim())
          .toList();
      if (relatedIds.isEmpty) {
        return [];
      }

      // Fetch related topics by IDs
      final placeholders = List.filled(relatedIds.length, '?').join(', ');
      final List<Map<String, dynamic>> results = await _topicsDb!.rawQuery(
        'SELECT * FROM ${DbConstants.topicsTable} WHERE ${DbConstants.topicIdCol} IN ($placeholders) ORDER BY ${DbConstants.arabicNameCol} ASC',
        relatedIds,
      );

      return results.map((row) => Topic.fromMap(row)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in getRelatedTopics fallback: $e');
      }
      return [];
    }
  }

  /// Fetches the parent topic from `parent_id`.
  Future<Topic?> getParentTopic(int parentId) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    try {
      return await getTopicById(parentId);
    } on DatabaseNotFoundException {
      return null;
    }
  }

  /// Fetches the root topics (e.g., parent_id IS NULL).
  Future<List<Topic>> getRootTopics() async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    try {
      final List<Map<String, dynamic>> results = await _topicsDb!.query(
        DbConstants.topicsTable,
        where: '${DbConstants.parentIdCol} IS NULL',
        orderBy: '${DbConstants.arabicNameCol} ASC',
      );

      return results.map((row) => Topic.fromMap(row)).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in getRootTopics: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Fetches root topics filtered by thematic or ontology hierarchy.
  /// If [thematic] is true, returns topics where thematic_parent_id IS NULL.
  /// If [thematic] is false, returns topics where ontology_parent_id IS NULL.
  Future<List<Topic>> getRootTopicsByHierarchy({required bool thematic}) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    try {
      final String parentIdCol = thematic
          ? DbConstants.thematicParentIdCol
          : DbConstants.ontologyParentIdCol;

      final List<Map<String, dynamic>> results = await _topicsDb!.query(
        DbConstants.topicsTable,
        where: '$parentIdCol IS NULL',
        orderBy: '${DbConstants.arabicNameCol} ASC',
      );

      return results.map((row) => Topic.fromMap(row)).toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in getRootTopicsByHierarchy: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Fetches all direct children of a given topic.
  Future<List<Topic>> getChildTopics(
    int topicId, {
    bool thematic = false,
  }) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    final String parentIdCol = thematic
        ? DbConstants.thematicParentIdCol
        : DbConstants.ontologyParentIdCol;

    final List<Map<String, dynamic>> results = await _topicsDb!.query(
      DbConstants.topicsTable,
      where: '$parentIdCol = ?',
      whereArgs: [topicId.toString()],
      orderBy: '${DbConstants.arabicNameCol} ASC',
    );

    return results.map((row) => Topic.fromMap(row)).toList();
  }

  /// Searches topics by name or Arabic name.
  Future<List<Topic>> searchTopics(String query) async {
    await ensureInitialized();
    if (_topicsDb == null) {
      throw DatabaseNotInitializedException("Topics DB not initialized");
    }

    // Validate and sanitize search query
    try {
      final sanitizedQuery = validateSearchQuery(query);
      query = sanitizedQuery;
    } on ArgumentError catch (e) {
      if (kDebugMode) {
        debugPrint('Invalid search query: $e');
      }
      return []; // Return empty results for invalid input
    }

    final searchPattern = '%$query%';

    final List<Map<String, dynamic>> results = await _topicsDb!.query(
      DbConstants.topicsTable,
      where:
          '${DbConstants.nameCol} LIKE ? OR ${DbConstants.arabicNameCol} LIKE ?',
      whereArgs: [searchPattern, searchPattern],
      orderBy: '${DbConstants.arabicNameCol} ASC',
      limit: SearchLimits.maxSearchResults,
    );

    return results.map((row) => Topic.fromMap(row)).toList();
  }
}
