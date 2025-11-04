import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kDebugMode and debugPrint
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/parsing_helpers.dart';
import '../utils/validation_helpers.dart';

class DatabaseService with InitializationMixin {
  Database? _layoutDb;
  Database? _scriptDb;
  Database? _metadataDb;
  Database? _juzDb;
  Database? _hizbDb;
  Database? _ayahTextDb;
  Database? _audioDb;

  List<Map<String, dynamic>> _juzCache = const [];
  List<Map<String, dynamic>> _hizbCache = const [];

  MushafLayout? _currentLayout;

  // WHY: This is the public 'init' method. It uses InitializationMixin for
  // thread-safe initialization while supporting layout parameterization.
  Future<void> init({MushafLayout? layout}) async {
    // If already initialized, don't change layout unless explicitly requested
    if (isInitialized) {
      if (layout != null && _currentLayout != layout) {
        // Only switch if different layout explicitly requested
        await switchLayout(layout);
      }
      // If already initialized and no layout change requested, return early
      return;
    }

    // Not initialized yet - use provided layout or default to Uthmani
    _currentLayout = layout ?? MushafLayout.uthmani15Lines;
    await ensureInitialized();
  }

  // WHY: Switch to a different layout after initialization
  Future<void> switchLayout(MushafLayout layout) async {
    if (!isInitialized) {
      await init(layout: layout);
      return;
    }

    // Close existing databases
    await _closeDatabases();

    // Reset initialization state (from mixin)
    resetInitializationState();

    // Initialize with new layout
    _currentLayout = layout;
    await ensureInitialized();
  }

  @override
  Future<void> doInit() async {
    // WHY: _currentLayout is set before calling ensureInitialized()
    if (_currentLayout == null) {
      throw StateError(
        'DatabaseService: Layout must be set before initialization',
      );
    }
    final layout = _currentLayout!;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    const dbAssetPath = 'assets/db';

    final databases = await Future.wait([
      _initDb(documentsDirectory, dbAssetPath, layout.layoutDatabaseFileName),
      _initDb(documentsDirectory, dbAssetPath, layout.scriptDatabaseFileName),
      _initDb(documentsDirectory, dbAssetPath, metadataDbFileName),
      _initDb(documentsDirectory, dbAssetPath, juzDbFileName),
      _initDb(documentsDirectory, dbAssetPath, hizbDbFileName),
      _initDb(documentsDirectory, dbAssetPath, imlaeiAyahDbFileName),
      _initDb(documentsDirectory, dbAssetPath, audioDbFileName),
    ]);

    _layoutDb = databases[0];
    _scriptDb = databases[1];
    _metadataDb = databases[2];
    _juzDb = databases[3];
    _hizbDb = databases[4];
    _ayahTextDb = databases[5];
    _audioDb = databases[6];

    // WHY: Load Juz and Hizb data into cache upon initialization for faster lookups later.
    if (_juzCache.isEmpty && _juzDb != null) {
      _juzCache = await _juzDb!.query(
        DbConstants.juzTable,
        orderBy: '${DbConstants.juzNumberCol} ASC',
      );
    }
    if (_hizbCache.isEmpty && _hizbDb != null) {
      _hizbCache = await _hizbDb!.query(
        DbConstants.hizbsTable,
        orderBy: '${DbConstants.hizbNumberCol} ASC',
      );
    }

    markInitialized();
  }

  Future<void> close() async {
    await _closeDatabases();
    resetInitializationState();
    _currentLayout = null;
  }

  Future<void> _closeDatabases() async {
    await Future.wait(
      [
        _layoutDb?.close(),
        _scriptDb?.close(),
        _metadataDb?.close(),
        _juzDb?.close(),
        _hizbDb?.close(),
        _ayahTextDb?.close(),
        _audioDb?.close(),
      ].where((future) => future != null).cast<Future<void>>(),
    );
  }

  Future<Database> _initDb(
    Directory docsDir,
    String assetPath,
    String fileName,
  ) async {
    final dbPath = p.join(docsDir.path, fileName);
    // WHY: Ensure the database file exists in the documents directory before opening.
    await _copyDbFromAssets(assetFileName: fileName, destinationPath: dbPath);

    // WHY: Configure database with timeout for concurrent access handling
    // Even read-only databases can experience locks during concurrent access
    final db = await openDatabase(
      dbPath,
      readOnly: true,
      singleInstance: true, // WHY: Reuse connection for better performance
    );

    // WHY: Set busy timeout for read-only databases to handle concurrent access.
    //
    // PLATFORM-SPECIFIC BEHAVIOR:
    // On iOS (SqfliteDarwinDatabase), executing PRAGMA statements on read-only
    // databases throws exceptions even though they're not actual errors (error
    // message explicitly says "not an error"). This is a platform-specific quirk.
    //
    // The FFI implementation used in tests allows PRAGMA on read-only databases,
    // but the native iOS implementation does not. This difference is why we must
    // wrap PRAGMA in try-catch to handle platform differences gracefully.
    //
    // The database is fully functional without the busy_timeout setting, so it's
    // safe to ignore these exceptions. The setting is "nice to have" but not
    // critical for functionality.
    try {
      await db.execute('PRAGMA busy_timeout=5000'); // 5 second timeout
    } catch (e) {
      // Ignore exceptions from PRAGMA on read-only databases.
      // This happens on iOS (SqfliteDarwinDatabase) but not on FFI (tests).
      // The database remains fully functional without this setting.
    }

    return db;
  }

  Future<void> _copyDbFromAssets({
    required String assetFileName,
    required String destinationPath,
  }) async {
    // Validate database file name against whitelist
    final allowedDbNames = [
      layoutDbFileName,
      indopakLayoutDbFileName,
      scriptDbFileName,
      indopakScriptDbFileName,
      metadataDbFileName,
      juzDbFileName,
      hizbDbFileName,
      imlaeiAyahDbFileName,
      topicsDbFileName,
      audioDbFileName,
    ];
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

    // WHY: In debug mode, always recopy databases to pick up changes during development.
    // In release mode, avoid recopying if the database already exists for performance.
    final shouldRecopy = kDebugMode || !await dbFile.exists();
    if (!shouldRecopy) {
      return;
    }
    try {
      // WHY: Load the database from assets and write it to the device's documents directory.
      final ByteData data = await rootBundle.load(
        p.join('assets/db', assetFileName),
      );
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.parent.create(recursive: true); // Ensure directory exists
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      throw DatabaseConnectionException(
        "Error copying database '$assetFileName' from assets",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches the text for a specific ayah.
  Future<String> getAyahText(int surahNumber, int ayahNumber) async {
    // Validate input parameters
    validateSurahAyah(surahNumber, ayahNumber);

    await init();
    if (_ayahTextDb == null) {
      throw DatabaseNotInitializedException(
        "Ayah text database is not initialized",
      );
    }

    final verseKey = '$surahNumber:$ayahNumber';

    try {
      final List<Map<String, dynamic>> result = await _ayahTextDb!.query(
        DbConstants.versesTable,
        columns: [DbConstants.textCol],
        where: '${DbConstants.verseKeyCol} = ?',
        whereArgs: [verseKey],
        limit: QueryLimits.singleResult,
      );

      if (result.isNotEmpty) {
        final String? text = result.first[DbConstants.textCol] as String?;
        if (text != null) {
          return text;
        }
      }
      return ''; // Return empty string if not found
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching ayah text for $verseKey: $e");
        // TODO: Include stackTrace when implementing crash analytics
        // catch (e, stackTrace) { ... debugPrint(stackTrace.toString()); }
      }
      return ''; // Return empty string on error
    }
  }

  /// Fetches texts for multiple ayahs in a single query (optimized for bulk operations).
  /// Returns a map from verse key (format: "surah:ayah") to text.
  /// WHY: This method eliminates N+1 query problems when fetching multiple ayah texts.
  Future<Map<String, String>> getAyahTextsBulk(
    List<({int surahNumber, int ayahNumber})> ayahs,
  ) async {
    await init();
    if (_ayahTextDb == null) {
      throw DatabaseNotInitializedException(
        "Ayah text database is not initialized",
      );
    }

    if (ayahs.isEmpty) {
      return {};
    }

    // Build verse keys and prepare query parameters
    final verseKeys = ayahs
        .map((ayah) => '${ayah.surahNumber}:${ayah.ayahNumber}')
        .toList();

    // Create placeholders for IN clause: (?, ?, ?, ...)
    final placeholders = List.filled(verseKeys.length, '?').join(', ');

    try {
      final List<Map<String, dynamic>> results = await _ayahTextDb!.query(
        DbConstants.versesTable,
        columns: [DbConstants.verseKeyCol, DbConstants.textCol],
        where: '${DbConstants.verseKeyCol} IN ($placeholders)',
        whereArgs: verseKeys,
      );

      // Build map from verse key to text
      final Map<String, String> ayahTexts = {};
      for (final row in results) {
        final verseKey = row[DbConstants.verseKeyCol] as String?;
        final text = row[DbConstants.textCol] as String?;
        if (verseKey != null && text != null) {
          ayahTexts[verseKey] = text;
        }
      }

      // Ensure all requested verse keys are in the map (even if empty string)
      for (final verseKey in verseKeys) {
        ayahTexts.putIfAbsent(verseKey, () => '');
      }

      return ayahTexts;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching bulk ayah texts: $e");
        // TODO: Include stackTrace when implementing crash analytics
        // catch (e, stackTrace) { ... debugPrint(stackTrace.toString()); }
      }
      // Return map with empty strings for all keys on error
      return Map.fromEntries(verseKeys.map((key) => MapEntry(key, '')));
    }
  }

  /// Search by Surah name to get the surah number
  Future<List<Map<String, dynamic>>> getSurahByName(String surahName) async {
    // Validate and sanitize surah name input
    // WHY: Prevent DoS attacks with extremely long strings and add defense in depth
    try {
      final sanitizedSurahName = validateSearchQuery(surahName);
      surahName = sanitizedSurahName;
    } on ArgumentError catch (e) {
      if (kDebugMode) {
        debugPrint('Invalid surah name query: $e');
      }
      // Return empty list for invalid input instead of throwing
      // This allows callers to handle gracefully (e.g., show "no results")
      return [];
    }

    await init();
    if (_metadataDb == null) {
      throw DatabaseNotInitializedException(
        "Metadata database for getSurahByName is not initialized",
      );
    }
    return _metadataDb!.query(
      DbConstants.chaptersTable,
      columns: [DbConstants.idCol],
      where: '${DbConstants.nameArabicCol} LIKE ?',
      whereArgs: ['%$surahName%'],
    );
  }

  /// Fetches all surahs with their names, revelation place, and starting page.
  Future<List<SurahInfo>> getAllSurahs() async {
    await init();
    if (_metadataDb == null || _layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Required databases for getAllSurahs are not initialized",
      );
    }

    // 1. Get all Surah metadata
    final List<Map<String, dynamic>> chapters = await _metadataDb!.query(
      DbConstants.chaptersTable,
      orderBy: '${DbConstants.idCol} ASC',
    );

    // 2. Get the starting page for each Surah (earliest page where surah_number appears).
    final List<Map<String, dynamic>>
    surahStartPages = await _layoutDb!.rawQuery(
      'SELECT ${DbConstants.surahNumberCol}, MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias} FROM ${DbConstants.pagesTable} WHERE ${DbConstants.surahNumberCol} > 0 GROUP BY ${DbConstants.surahNumberCol}',
    );

    // 3. Create a quick lookup map for page numbers (Surah Number -> Start Page).
    final Map<int, int> pageMap = Map.fromEntries(
      surahStartPages.map(
        (row) => MapEntry(
          parseInt(row[DbConstants.surahNumberCol]),
          parseInt(row[DbConstants.startPageAlias]),
        ),
      ),
    );
    // WHY: Surah Al-Fatiha starts on page 1, which might not be picked up by the query.
    pageMap[1] = 1;

    // 4. Combine the data into a list of SurahInfo objects.
    return chapters.map((chapter) {
      final int surahNum = parseInt(chapter[DbConstants.idCol]);
      // Use nullable casts and check for null
      // WHY: Type safety - database data may be corrupted
      final String? nameArabic = chapter[DbConstants.nameArabicCol] as String?;
      final String? revelationPlace =
          chapter[DbConstants.revelationPlaceCol] as String?;
      return SurahInfo(
        surahNumber: surahNum,
        nameArabic: nameArabic ?? '',
        revelationPlace: revelationPlace ?? '',
        startingPage: pageMap[surahNum] ?? 0, // Default to 0 if not found
      );
    }).toList();
  }

  /// Retrieves the Arabic name of a Surah given its ID (1-114).
  Future<String> getSurahName(int surahId) async {
    // Validate input parameter
    try {
      validateSurahNumber(surahId);
    } on ArgumentError {
      return ""; // Return empty string for invalid IDs
    }

    await init();
    if (_metadataDb == null) {
      throw DatabaseNotInitializedException("Metadata DB not initialized");
    }

    try {
      final List<Map<String, dynamic>> result = await _metadataDb!.query(
        DbConstants.chaptersTable,
        columns: [DbConstants.nameArabicCol],
        where: '${DbConstants.idCol} = ?',
        whereArgs: [surahId.toString()],
        limit: QueryLimits.singleResult,
      );
      if (result.isNotEmpty) {
        final String? nameArabic =
            result.first[DbConstants.nameArabicCol] as String?;
        if (nameArabic != null) {
          return nameArabic;
        }
      }
      return 'Surah $surahId'; // Fallback name
    } catch (e) {
      return 'Surah $surahId'; // Fallback on error
    }
  }

  // WHY: Use shared parsing utility instead of duplicate method
  // Removed parseInt() - use parseInt() from parsing_helpers.dart

  /// Determines the first Surah and Ayah number that appears on a given page.
  /// Public method for use by bookmarks service migration.
  Future<Map<String, int>> getFirstAyahOnPage(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber);
    return await _getFirstAyahOnPage(pageNumber);
  }

  /// Determines the first Surah and Ayah number that appears on a given page.
  Future<Map<String, int>> _getFirstAyahOnPage(int pageNumber) async {
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw DatabaseNotInitializedException(
        "Required DBs not initialized for _getFirstAyahOnPage",
      );
    }

    // Get all layout lines for the page, ordered.
    final List<Map<String, dynamic>> lines = await _layoutDb!.query(
      DbConstants.pagesTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: '${DbConstants.lineNumberCol} ASC',
    );

    if (lines.isEmpty) {
      throw DatabaseNotFoundException(
        "No layout data found for page $pageNumber",
      );
    }

    // WHY: Iterate through lines to find the first 'ayah' line with a valid word ID.
    for (final line in lines) {
      if (line[DbConstants.lineTypeCol] == 'ayah' &&
          line[DbConstants.firstWordIdCol] != null) {
        final firstWordId = parseInt(line[DbConstants.firstWordIdCol]);
        if (firstWordId == 0) continue; // Skip if ID is invalid

        // Query the script DB to get the Surah/Ayah for this word ID.
        final List<Map<String, dynamic>> words = await _scriptDb!.query(
          DbConstants.wordsTable,
          columns: [DbConstants.surahCol, DbConstants.ayahNumberCol],
          where: '${DbConstants.idCol} = ?',
          whereArgs: [firstWordId.toString()],
          limit: QueryLimits.singleResult,
        );
        if (words.isNotEmpty) {
          final int surah = parseInt(words.first[DbConstants.surahCol]);
          final int ayah = parseInt(words.first[DbConstants.ayahNumberCol]);

          // Validate parsed surah/ayah numbers before use
          // WHY: Defense in depth - validate even trusted database data
          try {
            validateSurahNumber(surah);
            validateAyahNumber(ayah);
            if (surah > 0 && ayah > 0) {
              return {'surah': surah, 'ayah': ayah}; // Found it
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Invalid surah/ayah in database: $surah:$ayah');
            }
            // Continue to next iteration
          }
        }
      }
    }
    // WHY: Fallback if no 'ayah' line found (e.g., page starts exactly with a Surah name).
    for (final line in lines) {
      if (line[DbConstants.lineTypeCol] == 'surah_name' &&
          line[DbConstants.surahNumberCol] != null) {
        final int surahNum = parseInt(line[DbConstants.surahNumberCol]);
        if (surahNum > 0) {
          return {'surah': surahNum, 'ayah': 1}; // Assume Ayah 1
        }
      }
    }

    // Should not happen with valid data, but throw if no Surah/Ayah found.
    throw DatabaseOperationException(
      "Could not determine first Surah/Ayah for page $pageNumber",
    );
  }

  /// Retrieves a list of all ayahs (surah and ayah numbers) on a given page.
  Future<List<Map<String, int>>> getAyahsOnPage(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber);

    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw DatabaseNotInitializedException(
        "Required DBs not initialized for getAyahsOnPage",
      );
    }

    // 1. Get all 'ayah' type lines for the page to find word ranges.
    final List<Map<String, dynamic>> lines = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.firstWordIdCol, DbConstants.lastWordIdCol],
      where:
          '${DbConstants.pageNumberCol} = ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [pageNumber.toString(), 'ayah'],
    );

    if (lines.isEmpty) {
      return [];
    }

    // 2. Collect all word IDs from all lines on the page.
    final wordIds = <int>{};
    for (final line in lines) {
      final firstWordId = parseInt(line[DbConstants.firstWordIdCol]);
      final lastWordId = parseInt(line[DbConstants.lastWordIdCol]);

      if (firstWordId > 0 && lastWordId > 0) {
        for (var i = firstWordId; i <= lastWordId; i++) {
          wordIds.add(i);
        }
      } else if (firstWordId > 0) {
        wordIds.add(firstWordId);
      }
    }

    if (wordIds.isEmpty) {
      return [];
    }

    // 3. Query the script DB to get unique surah/ayah pairs for these word IDs.
    // WHY: Use parameterized query with placeholders instead of string interpolation
    // to prevent SQL injection vulnerabilities.
    final wordIdsList = wordIds.toList();
    final placeholders = List.filled(wordIdsList.length, '?').join(', ');
    final List<Map<String, dynamic>> words = await _scriptDb!.query(
      DbConstants.wordsTable,
      distinct: true,
      columns: [DbConstants.surahCol, DbConstants.ayahNumberCol],
      where: '${DbConstants.idCol} IN ($placeholders)',
      whereArgs: wordIdsList,
    );

    // 4. Map the results to the required format.
    return words
        .map(
          (word) => {
            'surah': parseInt(word[DbConstants.surahCol]),
            'ayah': parseInt(word[DbConstants.ayahNumberCol]),
          },
        )
        .where((ayah) => ayah['surah']! > 0 && ayah['ayah']! > 0)
        .toList();
  }

  /// Checks if a given ayah (s:a) falls within a range (sFirst:aFirst to sLast:aLast).
  bool _isAyahInRange(
    int s,
    int a,
    int sFirst,
    int aFirst,
    int sLast,
    int aLast,
  ) {
    if (s < sFirst || s > sLast) return false; // Surah out of range
    if (s == sFirst && a < aFirst) return false; // Ayah before range start
    if (s == sLast && a > aLast) return false; // Ayah after range end
    return true;
  }

  /// Finds the Juz' number containing a specific Surah and Ayah using the cached Juz' data.
  int _findJuz(int pageSurah, int pageAyah) {
    if (_juzCache.isEmpty) return 0; // Cache not loaded
    // Iterate through cached Juz' ranges.
    for (final row in _juzCache) {
      final firstKey = row[DbConstants.firstVerseKeyCol] as String?;
      final lastKey = row[DbConstants.lastVerseKeyCol] as String?;
      if (firstKey == null || lastKey == null) continue; // Skip invalid data

      try {
        // Parse the start and end Surah:Ayah keys.
        // WHY: Validate split results before parsing
        final firstParts = firstKey.split(':');
        final lastParts = lastKey.split(':');
        if (firstParts.length != 2 ||
            lastParts.length != 2 ||
            firstParts[0].isEmpty ||
            firstParts[1].isEmpty ||
            lastParts[0].isEmpty ||
            lastParts[1].isEmpty) {
          continue; // Skip invalid keys
        }

        final int sFirst = parseInt(firstParts[0]);
        final int aFirst = parseInt(firstParts[1]);
        final int sLast = parseInt(lastParts[0]);
        final int aLast = parseInt(lastParts[1]);

        // Validate parsed surah/ayah numbers before use
        // WHY: Defense in depth - validate even trusted database data
        try {
          validateSurahNumber(sFirst);
          validateAyahNumber(aFirst);
          validateSurahNumber(sLast);
          validateAyahNumber(aLast);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Invalid surah/ayah in Juz keys: $firstKey, $lastKey');
          }
          continue; // Skip invalid entries
        }

        // Check if the target ayah falls within this Juz' range.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return parseInt(row[DbConstants.juzNumberCol]); // Found it
        }
      } catch (_) {
        continue; // Ignore errors parsing keys
      }
    }
    return 0; // Not found
  }

  /// Finds the Hizb number containing a specific Surah and Ayah using the cached Hizb data.
  int _findHizb(int pageSurah, int pageAyah) {
    if (_hizbCache.isEmpty) return 0; // Cache not loaded
    // Iterate through cached Hizb ranges.
    for (final row in _hizbCache) {
      final firstKey = row[DbConstants.firstVerseKeyCol] as String?;
      final lastKey = row[DbConstants.lastVerseKeyCol] as String?;
      if (firstKey == null || lastKey == null) continue; // Skip invalid data

      try {
        // Parse the start and end Surah:Ayah keys.
        // WHY: Validate split results before parsing
        final firstParts = firstKey.split(':');
        final lastParts = lastKey.split(':');
        if (firstParts.length != 2 ||
            lastParts.length != 2 ||
            firstParts[0].isEmpty ||
            firstParts[1].isEmpty ||
            lastParts[0].isEmpty ||
            lastParts[1].isEmpty) {
          continue; // Skip invalid keys
        }

        final int sFirst = parseInt(firstParts[0]);
        final int aFirst = parseInt(firstParts[1]);
        final int sLast = parseInt(lastParts[0]);
        final int aLast = parseInt(lastParts[1]);

        // Validate parsed surah/ayah numbers before use
        // WHY: Defense in depth - validate even trusted database data
        try {
          validateSurahNumber(sFirst);
          validateAyahNumber(aFirst);
          validateSurahNumber(sLast);
          validateAyahNumber(aLast);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Invalid surah/ayah in Hizb keys: $firstKey, $lastKey');
          }
          continue; // Skip invalid entries
        }

        // Check if the target ayah falls within this Hizb range.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return parseInt(row[DbConstants.hizbNumberCol]); // Found it
        }
      } catch (_) {
        continue; // Ignore errors parsing keys
      }
    }
    return 0; // Not found
  }

  /// Retrieves header information (Juz', Hizb, Surah Name, Surah Number) for a given page.
  Future<Map<String, dynamic>> getPageHeaderInfo(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber);

    await init();
    try {
      // Find the first ayah on the page to determine context.
      final firstAyah = await _getFirstAyahOnPage(pageNumber);
      final pageSurah = firstAyah['surah']!;
      final pageAyah = firstAyah['ayah']!;

      // Use cached lookups for Juz' and Hizb.
      final juzNumber = _findJuz(pageSurah, pageAyah);
      final hizbNumber = _findHizb(pageSurah, pageAyah);
      // Fetch Surah name if applicable.
      final surahName = (pageSurah > 0) ? await getSurahName(pageSurah) : "";

      return {
        'juz': juzNumber,
        'hizb': hizbNumber,
        'surahName': surahName,
        'surahNumber': pageSurah,
      };
    } catch (e) {
      // Return default values on error.
      return {'juz': 0, 'hizb': 0, 'surahName': '', 'surahNumber': 0};
    }
  }

  /// Retrieves the complete layout (lines and words) for a given page number.
  Future<PageLayout> getPageLayout(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber);

    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw DatabaseNotInitializedException(
        "Required DBs not initialized for getPageLayout",
      );
    }

    // Get all layout lines for the page.
    final List<Map<String, dynamic>> linesData = await _layoutDb!.query(
      DbConstants.pagesTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: '${DbConstants.lineNumberCol} ASC',
    );

    if (linesData.isEmpty) {
      throw DatabaseNotFoundException(
        "No layout data found for page $pageNumber",
      );
    }

    List<LineInfo> lines = [];
    // Process each line to fetch words or surah name.
    for (var lineData in linesData) {
      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted or schema may change
      final String? lineTypeNullable =
          lineData[DbConstants.lineTypeCol] as String?;
      if (lineTypeNullable == null) {
        if (kDebugMode) {
          debugPrint('Missing line type in database result');
        }
        continue; // Skip invalid entries
      }
      final String lineType = lineTypeNullable;
      List<Word> words = [];
      String? surahName;
      final int surahNum = parseInt(lineData[DbConstants.surahNumberCol]);

      if (lineType == 'ayah') {
        final firstWordId = parseInt(lineData[DbConstants.firstWordIdCol]);
        final lastWordId = parseInt(lineData[DbConstants.lastWordIdCol]);

        // Fetch words within the ID range for this line.
        if (firstWordId > 0 && lastWordId >= firstWordId) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            DbConstants.wordsTable,
            // WHY: Include surah and ayah for each word, needed for memorization logic.
            columns: [
              DbConstants.textCol,
              DbConstants.surahCol,
              DbConstants.ayahNumberCol,
            ],
            where: '${DbConstants.idCol} BETWEEN ? AND ?',
            whereArgs: [firstWordId.toString(), lastWordId.toString()],
            orderBy: '${DbConstants.idCol} ASC',
          );
          words = wordsData.map((wordMap) {
            // Use nullable cast and check for null
            // WHY: Type safety - database data may be corrupted
            final String? text = wordMap[DbConstants.textCol] as String?;
            if (text == null) {
              if (kDebugMode) {
                debugPrint('Missing word text in database result');
              }
              // Return a word with empty text as safe default
              return Word(
                text: '',
                surahNumber: parseInt(wordMap[DbConstants.surahCol]),
                ayahNumber: parseInt(wordMap[DbConstants.ayahNumberCol]),
              );
            }
            return Word(
              text: text,
              surahNumber: parseInt(wordMap[DbConstants.surahCol]),
              ayahNumber: parseInt(wordMap[DbConstants.ayahNumberCol]),
            );
          }).toList();
        }
        // Handle lines with only one word.
        else if (firstWordId > 0 &&
            (lastWordId == 0 || lastWordId < firstWordId)) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            DbConstants.wordsTable,
            columns: [
              DbConstants.textCol,
              DbConstants.surahCol,
              DbConstants.ayahNumberCol,
            ],
            where: '${DbConstants.idCol} = ?',
            whereArgs: [firstWordId.toString()],
            limit: QueryLimits.singleResult,
          );
          words = wordsData.map((wordMap) {
            // Use nullable cast and check for null
            // WHY: Type safety - database data may be corrupted
            final String? text = wordMap[DbConstants.textCol] as String?;
            if (text == null) {
              if (kDebugMode) {
                debugPrint('Missing word text in database result');
              }
              // Return a word with empty text as safe default
              return Word(
                text: '',
                surahNumber: parseInt(wordMap[DbConstants.surahCol]),
                ayahNumber: parseInt(wordMap[DbConstants.ayahNumberCol]),
              );
            }
            return Word(
              text: text,
              surahNumber: parseInt(wordMap[DbConstants.surahCol]),
              ayahNumber: parseInt(wordMap[DbConstants.ayahNumberCol]),
            );
          }).toList();
        }
      } else if (lineType == 'surah_name') {
        // Fetch Surah name if it's a surah_name line.
        if (surahNum > 0) {
          surahName = await getSurahName(surahNum);
        }
      }

      // Add the processed line info to the list.
      lines.add(
        LineInfo(
          lineNumber: parseInt(lineData[DbConstants.lineNumberCol]),
          isCentered: parseInt(lineData[DbConstants.isCenteredCol]) == 1,
          lineType: lineType,
          surahNumber: surahNum,
          words: words,
          surahName: surahName,
        ),
      );
    }
    // Return the complete page layout.
    return PageLayout(pageNumber: pageNumber, lines: lines);
  }

  /// Gets audio information for a specific surah.
  Future<SurahAudio?> getSurahAudio(int surahNumber) async {
    await init();
    if (_audioDb == null) {
      throw DatabaseNotInitializedException(
        "Audio database is not initialized",
      );
    }

    try {
      final List<Map<String, dynamic>> result = await _audioDb!.query(
        DbConstants.surahListTable,
        where: '${DbConstants.surahNumberCol} = ?',
        whereArgs: [surahNumber.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) {
        return null;
      }

      final row = result.first;
      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted
      final String? audioUrl = row[DbConstants.audioUrlCol] as String?;
      if (audioUrl == null) {
        throw DatabaseNotFoundException(
          "Surah audio URL not found for surah $surahNumber",
        );
      }
      return SurahAudio(
        surahNumber: parseInt(row[DbConstants.surahNumberCol]),
        audioUrl: audioUrl,
        duration: parseInt(row[DbConstants.durationCol]),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching surah audio for $surahNumber: $e");
      }
      return null;
    }
  }

  /// Gets segment information for a specific ayah.
  Future<AyahSegment?> getAyahSegment(int surahNumber, int ayahNumber) async {
    await init();
    if (_audioDb == null) {
      throw DatabaseNotInitializedException(
        "Audio database is not initialized",
      );
    }

    try {
      final List<Map<String, dynamic>> result = await _audioDb!.query(
        DbConstants.segmentsTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.audioAyahNumberCol} = ?',
        whereArgs: [surahNumber.toString(), ayahNumber.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) {
        return null;
      }

      final row = result.first;
      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted
      final String? segments = row[DbConstants.segmentsCol] as String?;
      if (segments == null) {
        throw DatabaseNotFoundException(
          "Ayah segment data not found for $surahNumber:$ayahNumber",
        );
      }
      return AyahSegment(
        surahNumber: parseInt(row[DbConstants.surahNumberCol]),
        ayahNumber: parseInt(row[DbConstants.audioAyahNumberCol]),
        durationSec: parseInt(row[DbConstants.durationSecCol]),
        timestampFrom: parseInt(row[DbConstants.timestampFromCol]),
        timestampTo: parseInt(row[DbConstants.timestampToCol]),
        segments: segments,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "Error fetching ayah segment for $surahNumber:$ayahNumber: $e",
        );
      }
      return null;
    }
  }

  /// Gets all segments for a specific surah.
  Future<List<AyahSegment>> getSurahSegments(int surahNumber) async {
    await init();
    if (_audioDb == null) {
      throw DatabaseNotInitializedException(
        "Audio database is not initialized",
      );
    }

    try {
      final List<Map<String, dynamic>> results = await _audioDb!.query(
        DbConstants.segmentsTable,
        where: '${DbConstants.surahNumberCol} = ?',
        whereArgs: [surahNumber.toString()],
        orderBy: '${DbConstants.audioAyahNumberCol} ASC',
      );

      return results
          .map((row) {
            // Use nullable cast and check for null
            // WHY: Type safety - database data may be corrupted
            final String? segments = row[DbConstants.segmentsCol] as String?;
            if (segments == null) {
              // Skip invalid entries - database data may be corrupted
              if (kDebugMode) {
                debugPrint(
                  'Missing segments data for surah ${row[DbConstants.surahNumberCol]}:${row[DbConstants.audioAyahNumberCol]}',
                );
              }
              return null;
            }
            return AyahSegment(
              surahNumber: parseInt(row[DbConstants.surahNumberCol]),
              ayahNumber: parseInt(row[DbConstants.audioAyahNumberCol]),
              durationSec: parseInt(row[DbConstants.durationSecCol]),
              timestampFrom: parseInt(row[DbConstants.timestampFromCol]),
              timestampTo: parseInt(row[DbConstants.timestampToCol]),
              segments: segments,
            );
          })
          .whereType<AyahSegment>() // Filter out null values
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching surah segments for $surahNumber: $e");
      }
      return [];
    }
  }

  /// Finds the page number containing the start of a specific ayah.
  Future<int> getPageForAyah(int surahNumber, int ayahNumber) async {
    // Validate input parameters
    validateSurahAyah(surahNumber, ayahNumber);

    await init();
    if (_scriptDb == null || _layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Required DBs not initialized for getPageForAyah",
      );
    }

    // 1. Find the first word ID for the given surah and ayah.
    final List<Map<String, dynamic>> words = await _scriptDb!.query(
      DbConstants.wordsTable,
      columns: [DbConstants.idCol],
      where: '${DbConstants.surahCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
      whereArgs: [surahNumber.toString(), ayahNumber.toString()],
      orderBy: '${DbConstants.idCol} ASC',
      limit: QueryLimits.singleResult,
    );

    if (words.isEmpty) {
      // Fallback: If ayah 1 doesn't exist (e.g., invalid input), try finding page for surah start
      if (ayahNumber == 1) {
        return getPageForSurah(surahNumber);
      }
      throw DatabaseNotFoundException(
        "Word not found for Surah $surahNumber, Ayah $ayahNumber",
      );
    }
    // Defense in depth: Check isEmpty before accessing .first
    // WHY: Even though we checked above, this provides additional safety
    if (words.isEmpty) {
      if (kDebugMode) {
        debugPrint('Unexpected empty words list after isEmpty check');
      }
      throw DatabaseNotFoundException(
        "Word not found for Surah $surahNumber, Ayah $ayahNumber",
      );
    }
    final int firstWordId = parseInt(words.first[DbConstants.idCol]);

    // 2. Find the page layout entry containing this word ID.
    // Check if the word ID falls within the first_word_id and last_word_id range.
    final List<Map<String, dynamic>> pages = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.pageNumberCol],
      where:
          '${DbConstants.firstWordIdCol} <= ? AND ${DbConstants.lastWordIdCol} >= ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [firstWordId.toString(), firstWordId.toString(), 'ayah'],
      orderBy:
          '${DbConstants.pageNumberCol} ASC, ${DbConstants.lineNumberCol} ASC', // Ensure the earliest occurrence
      limit: QueryLimits.singleResult,
    );

    if (pages.isNotEmpty) {
      return parseInt(pages.first[DbConstants.pageNumberCol]);
    }

    // Fallback: Check if it's the very first word on a line (last_word_id might be 0 or equal)
    final List<Map<String, dynamic>> firstWordPages = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.pageNumberCol],
      where:
          '${DbConstants.firstWordIdCol} = ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [firstWordId.toString(), 'ayah'],
      orderBy:
          '${DbConstants.pageNumberCol} ASC, ${DbConstants.lineNumberCol} ASC',
      limit: QueryLimits.singleResult,
    );

    if (firstWordPages.isNotEmpty) {
      return parseInt(firstWordPages.first[DbConstants.pageNumberCol]);
    }

    // Final fallback specifically for Surah starts (like Surah 1 page 1)
    if (ayahNumber == 1) {
      return getPageForSurah(surahNumber);
    }

    throw DatabaseNotFoundException(
      "Page not found containing word ID $firstWordId (Surah $surahNumber, Ayah $ayahNumber)",
    );
  }

  /// Helper to get the starting page number for a Surah.
  Future<int> getPageForSurah(int surahNumber) async {
    await init();
    if (_layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Layout DB not initialized for getPageForSurah",
      );
    }
    // Manually handle Surah 1 starting on page 1
    if (surahNumber == 1) return 1;

    // Try finding the page where the 'surah_name' line appears first.
    final List<Map<String, dynamic>> result = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [
        'MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias}',
      ],
      where:
          '${DbConstants.surahNumberCol} = ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [surahNumber.toString(), 'surah_name'],
      limit: QueryLimits.singleResult,
    );

    if (result.isNotEmpty && result.first[DbConstants.startPageAlias] != null) {
      return parseInt(result.first[DbConstants.startPageAlias]);
    }
    // Broader fallback if surah_name line isn't found (look for any line with that surah_number).
    final List<Map<String, dynamic>> broaderResult = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [
        'MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias}',
      ],
      where: '${DbConstants.surahNumberCol} = ?',
      whereArgs: [surahNumber.toString()],
      limit: QueryLimits.singleResult,
    );
    if (broaderResult.isNotEmpty &&
        broaderResult.first[DbConstants.startPageAlias] != null) {
      return parseInt(broaderResult.first[DbConstants.startPageAlias]);
    }

    throw DatabaseNotFoundException(
      "Starting page not found for Surah $surahNumber",
    );
  }

  /// Retrieves information (number and starting page) for all 30 Juz'.
  Future<List<JuzInfo>> getAllJuzInfo() async {
    await init();
    if (_juzCache.isEmpty) {
      throw DatabaseNotInitializedException(
        "Juz' data cache is empty or not initialized",
      );
    }

    List<JuzInfo> juzList = [];
    // Process each Juz' entry from the cache.
    for (final juzData in _juzCache) {
      final int juzNum = parseInt(juzData[DbConstants.juzNumberCol]);
      final String? firstVerseKey =
          juzData[DbConstants.firstVerseKeyCol] as String?;

      if (firstVerseKey != null && firstVerseKey.isNotEmpty) {
        try {
          // Parse Surah:Ayah from the key.
          // WHY: Validate split results before parsing
          final parts = firstVerseKey.split(':');
          if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
            if (kDebugMode) {
              debugPrint(
                "Warning: Invalid verse key format '$firstVerseKey' for Juz $juzNum",
              );
            }
            continue; // Skip invalid keys
          }

          final int surah = parseInt(parts[0]);
          final int ayah = parseInt(parts[1]);

          // Validate parsed surah/ayah numbers before use
          // WHY: Defense in depth - validate even trusted database data
          try {
            validateSurahNumber(surah);
            validateAyahNumber(ayah);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                "Warning: Invalid surah/ayah in verse key '$firstVerseKey' for Juz $juzNum",
              );
            }
            continue; // Skip invalid entries
          }

          // Find the page number for the starting ayah of this Juz'.
          // Safe to use validated surah and ayah
          final int startPage = await getPageForAyah(surah, ayah);
          juzList.add(JuzInfo(juzNumber: juzNum, startingPage: startPage));
        } catch (e) {
          // Log errors during processing but continue.
          if (kDebugMode) {
            debugPrint("Error processing Juz $juzNum start page lookup: $e");
            // TODO: Include stackTrace when implementing crash analytics
            // catch (e, stackTrace) { ... debugPrint(stackTrace.toString()); }
          }
        }
      }
    }
    // Return the list of successfully processed Juz' info.
    return juzList;
  }

  /// Gets the last ayah on a specific page.
  Future<Map<String, int>?> getLastAyahOnPage(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber);

    await init();
    try {
      final ayahs = await getAyahsOnPage(pageNumber);
      if (ayahs.isEmpty) return null;

      // Sort by surah number, then ayah number to get the last one
      ayahs.sort((a, b) {
        final surahCompare = a['surah']!.compareTo(b['surah']!);
        if (surahCompare != 0) return surahCompare;
        return a['ayah']!.compareTo(b['ayah']!);
      });

      return ayahs.last;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting last ayah on page $pageNumber: $e');
      }
      return null;
    }
  }

  /// Gets the last ayah number in a specific surah.
  Future<int?> getLastAyahInSurah(int surahNumber) async {
    await init();
    try {
      final segments = await getSurahSegments(surahNumber);
      if (segments.isEmpty) return null;

      // Segments are already ordered by ayah number ASC, so get the last one
      return segments.last.ayahNumber;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting last ayah in surah $surahNumber: $e');
      }
      return null;
    }
  }

  /// Gets the last ayah in a specific juz.
  Future<Map<String, int>?> getLastAyahInJuz(int juzNumber) async {
    await init();
    if (_juzCache.isEmpty) return null;

    try {
      // Find the juz in cache
      final juzData = _juzCache.firstWhere(
        (row) => parseInt(row[DbConstants.juzNumberCol]) == juzNumber,
        orElse: () => <String, dynamic>{},
      );

      if (juzData.isEmpty) return null;

      final lastKey = juzData[DbConstants.lastVerseKeyCol] as String?;
      if (lastKey == null || lastKey.isEmpty) return null;

      // Parse the last verse key (format: "surah:ayah")
      // WHY: Validate split results before parsing
      final parts = lastKey.split(':');
      if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
        return null; // Invalid format
      }

      final int surah = parseInt(parts[0]);
      final int ayah = parseInt(parts[1]);

      // Validate parsed surah/ayah numbers before use
      // WHY: Defense in depth - validate even trusted database data
      try {
        validateSurahNumber(surah);
        validateAyahNumber(ayah);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Invalid surah/ayah in last key: $lastKey');
        }
        return null; // Invalid values
      }

      return {'surah': surah, 'ayah': ayah};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting last ayah in juz $juzNumber: $e');
      }
      return null;
    }
  }

  /// Gets the juz number for a specific surah and ayah.
  Future<int?> getJuzForAyah(int surahNumber, int ayahNumber) async {
    await init();
    try {
      final juzNumber = _findJuz(surahNumber, ayahNumber);
      return juzNumber > 0 ? juzNumber : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Error getting juz for surah $surahNumber, ayah $ayahNumber: $e',
        );
      }
      return null;
    }
  }

  /// Retrieves the total number of pages for the current layout.
  /// Reads from the 'info' table's 'number_of_pages' column in the layout database.
  Future<int> getTotalPages() async {
    await init();
    if (_layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Layout database is not initialized for getTotalPages",
      );
    }

    try {
      final List<Map<String, dynamic>> result = await _layoutDb!.query(
        DbConstants.infoTable,
        columns: [DbConstants.numberOfPagesCol],
        limit: QueryLimits.singleResult,
      );

      if (result.isNotEmpty &&
          result.first[DbConstants.numberOfPagesCol] != null) {
        return parseInt(result.first[DbConstants.numberOfPagesCol]);
      }

      // Fallback to 604 if info table doesn't exist or has no data
      // This should never happen with valid databases, but provides safety
      if (kDebugMode) {
        debugPrint(
          'Warning: number_of_pages not found in info table, using fallback value',
        );
      }
      return 604;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error retrieving total pages from database: $e');
      }
      // Fallback to 604 on error
      return 604;
    }
  }

  /// Retrieves layout information (name and lines_per_page) from the info table.
  /// Reads from the 'info' table in the layout database.
  Future<LayoutInfo> getLayoutInfo() async {
    await init();
    if (_layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Layout database is not initialized for getLayoutInfo",
      );
    }

    try {
      final List<Map<String, dynamic>> result = await _layoutDb!.query(
        DbConstants.infoTable,
        columns: [DbConstants.layoutNameCol, DbConstants.linesPerPageCol],
        limit: QueryLimits.singleResult,
      );

      if (result.isNotEmpty) {
        final name = result.first[DbConstants.layoutNameCol] as String?;
        final linesPerPage = result.first[DbConstants.linesPerPageCol];

        if (name != null && linesPerPage != null) {
          return LayoutInfo(name: name, linesPerPage: parseInt(linesPerPage));
        }
      }

      // Fallback if info table doesn't exist or has no data
      if (kDebugMode) {
        debugPrint(
          'Warning: layout info not found in info table, using fallback values',
        );
      }
      // Default fallback values based on current layout
      return LayoutInfo(
        name: _currentLayout == MushafLayout.indopak13Lines
            ? 'Indopak'
            : 'Uthmani Hafs',
        linesPerPage: _currentLayout == MushafLayout.indopak13Lines ? 13 : 15,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error retrieving layout info from database: $e');
      }
      // Fallback on error
      return LayoutInfo(
        name: _currentLayout == MushafLayout.indopak13Lines
            ? 'Indopak'
            : 'Uthmani Hafs',
        linesPerPage: _currentLayout == MushafLayout.indopak13Lines ? 13 : 15,
      );
    }
  }

  /// Retrieves layout information for a specific layout without switching to it.
  /// Opens the layout's database temporarily to read from the info table.
  Future<LayoutInfo> getLayoutInfoForLayout(MushafLayout layout) async {
    // If this is the current layout, use the existing database connection
    if (_currentLayout == layout && _layoutDb != null) {
      try {
        final List<Map<String, dynamic>> result = await _layoutDb!.query(
          DbConstants.infoTable,
          columns: [DbConstants.layoutNameCol, DbConstants.linesPerPageCol],
          limit: QueryLimits.singleResult,
        );

        if (result.isNotEmpty) {
          final name = result.first[DbConstants.layoutNameCol] as String?;
          final linesPerPage = result.first[DbConstants.linesPerPageCol];

          if (name != null && linesPerPage != null) {
            return LayoutInfo(name: name, linesPerPage: parseInt(linesPerPage));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error retrieving layout info for current layout: $e');
        }
      }
    }

    // For other layouts, open the database temporarily
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      const dbAssetPath = 'assets/db';
      final db = await _initDb(
        documentsDirectory,
        dbAssetPath,
        layout.layoutDatabaseFileName,
      );

      try {
        final List<Map<String, dynamic>> result = await db.query(
          DbConstants.infoTable,
          columns: [DbConstants.layoutNameCol, DbConstants.linesPerPageCol],
          limit: QueryLimits.singleResult,
        );

        if (result.isNotEmpty) {
          final name = result.first[DbConstants.layoutNameCol] as String?;
          final linesPerPage = result.first[DbConstants.linesPerPageCol];

          if (name != null && linesPerPage != null) {
            return LayoutInfo(name: name, linesPerPage: parseInt(linesPerPage));
          }
        }
      } finally {
        await db.close();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error retrieving layout info for layout $layout: $e');
      }
    }

    // Fallback values
    return LayoutInfo(
      name: layout == MushafLayout.indopak13Lines ? 'Indopak' : 'Uthmani Hafs',
      linesPerPage: layout == MushafLayout.indopak13Lines ? 13 : 15,
    );
  }

  /// Retrieves the text of the first 'count' words appearing on a specific page.
  Future<String> getFirstWordsOfPage(int pageNumber, {int count = 3}) async {
    // Validate input parameter
    validatePageNumber(pageNumber);

    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw DatabaseNotInitializedException(
        "Required DBs not initialized for getFirstWordsOfPage",
      );
    }

    // 1. Find the first 'ayah' line on the page that has words.
    final List<Map<String, dynamic>> lines = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.firstWordIdCol, DbConstants.lastWordIdCol],
      where:
          '${DbConstants.pageNumberCol} = ? AND ${DbConstants.lineTypeCol} = ? AND ${DbConstants.firstWordIdCol} > 0',
      whereArgs: [pageNumber.toString(), 'ayah'],
      orderBy: '${DbConstants.lineNumberCol} ASC',
      limit: PreviewLimits
          .maxPreviewLines, // WHY: Fetch a few lines in case the very first is empty/basmallah
    );

    int firstWordId = 0;
    // Find the first line in the results that actually has a word id > 0
    for (var line in lines) {
      int currentFirstWordId = parseInt(line[DbConstants.firstWordIdCol]);
      if (currentFirstWordId > 0) {
        // Check if this word is part of Basmallah (often ayah 0)
        final List<Map<String, dynamic>> checkWord = await _scriptDb!.query(
          DbConstants.wordsTable,
          columns: [DbConstants.ayahNumberCol],
          where: '${DbConstants.idCol} = ?',
          whereArgs: [currentFirstWordId.toString()],
          limit: QueryLimits.singleResult,
        );
        if (checkWord.isNotEmpty &&
            parseInt(checkWord.first[DbConstants.ayahNumberCol]) > 0) {
          firstWordId = currentFirstWordId;
          break; // Found the first non-Basmallah word
        } else if (firstWordId == 0) {
          // Store the potential Basmallah word ID just in case no other words are found
          firstWordId = currentFirstWordId;
        }
      }
    }

    // If no valid starting word was found after checking lines
    if (firstWordId == 0) {
      if (kDebugMode) {
        debugPrint(
          "Warning: No valid starting word ID found for preview on page $pageNumber.",
        );
      }
      return "";
    }

    // 2. Fetch the required number of words starting from that ID.
    final List<Map<String, dynamic>> words = await _scriptDb!.query(
      DbConstants.wordsTable,
      columns: [DbConstants.textCol],
      where: '${DbConstants.idCol} >= ?',
      whereArgs: [firstWordId.toString()],
      orderBy: '${DbConstants.idCol} ASC',
      limit: count,
    );

    // 3. Join the text of the words.
    // Use nullable cast and filter out null values
    // WHY: Type safety - database data may be corrupted
    return words
        .map((w) => w[DbConstants.textCol] as String?)
        .whereType<String>()
        .join(' ');
  }
}
