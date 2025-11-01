import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/lru_cache.dart';
import 'database_service.dart';

/// Service for searching Quranic text
class SearchService with InitializationMixin {
  final DatabaseService _databaseService;
  Database? _imlaeiDb; // Database with searchable Arabic text
  Database? _imlaeiScriptDb; // Database with ayah-by-ayah script text

  // WHY: Use LRU caches to limit memory usage and prevent unbounded growth.
  // Evicts least recently used items when cache is full.
  final LRUCache<String, List<SearchResult>> _searchCache =
      LRUCache<String, List<SearchResult>>(
        SearchCacheLimits.maxSearchCacheSize,
      );
  final LRUCache<int, String> _surahNameCache = LRUCache<int, String>(
    SearchCacheLimits.maxSurahNameCacheSize,
  );
  final LRUCache<String, int> _verseToPageCache = LRUCache<String, int>(
    SearchCacheLimits.maxVerseToPageCacheSize,
  ); // Cache verse_key -> page_number

  MushafLayout? _currentLayout;

  SearchService(this._databaseService);

  /// Initialize the search service with the current layout
  /// Uses InitializationMixin for thread-safe initialization while
  /// supporting layout parameterization.
  Future<void> init({MushafLayout layout = MushafLayout.uthmani15Lines}) async {
    // If already initialized with the same layout, return early
    if (isInitialized && _currentLayout == layout) return;

    // If initialized with different layout, reset and reinitialize
    if (isInitialized && _currentLayout != layout) {
      await switchLayout(layout);
      return;
    }

    // Store layout before initialization
    _currentLayout = layout;
    await ensureInitialized();
  }

  /// Switch to a different layout for search
  Future<void> switchLayout(MushafLayout layout) async {
    if (!isInitialized) {
      await init(layout: layout);
      return;
    }

    // Clear caches
    _searchCache.clear();
    _surahNameCache.clear();
    _verseToPageCache.clear();

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
        'SearchService: Layout must be set before initialization',
      );
    }
    // Note: layout is stored but not used directly in doInit for SearchService
    // since it uses the same databases regardless of layout
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      const dbAssetPath = 'assets/db';

      // Initialize all databases using the same pattern as DatabaseService
      final databases = await Future.wait([
        _initDb(documentsDirectory, dbAssetPath, 'imlaei-simple.db'),
        _initDb(
          documentsDirectory,
          dbAssetPath,
          'imlaei-script-ayah-by-ayah.db',
        ),
      ]);

      _imlaeiDb = databases[0];
      _imlaeiScriptDb = databases[1];

      markInitialized();
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error initializing SearchService',
          name: 'SearchService',
          error: e,
        );
      }
      rethrow;
    }
  }

  Future<void> _closeDatabases() async {
    await Future.wait(
      [
        _imlaeiDb?.close(),
        _imlaeiScriptDb?.close(),
      ].where((future) => future != null).cast<Future<void>>(),
    );
    _imlaeiDb = null;
    _imlaeiScriptDb = null;
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
    final dbFile = File(destinationPath);
    // WHY: Avoid recopying if the database already exists.
    if (await dbFile.exists()) {
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

  /// Search for Arabic text in the Quran
  Future<List<SearchResult>> searchText(String query) async {
    await init();

    if (query.trim().isEmpty) return [];

    // Check cache first
    final cacheKey = query.trim().toLowerCase();
    final cachedResults = _searchCache.get(cacheKey);
    if (cachedResults != null) {
      return cachedResults;
    }

    if (_imlaeiDb == null || _imlaeiScriptDb == null) {
      throw DatabaseNotInitializedException(
        'SearchService databases not initialized',
      );
    }

    try {
      // Search in both databases and combine results without duplicates
      List<SearchResult> results = await _searchInBothDatabases(query);

      // Cache results
      _searchCache.put(cacheKey, results);

      return results;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error searching text', name: 'SearchService', error: e);
      }
      return [];
    }
  }

  /// Search in both imlaei databases and combine results without duplicates
  Future<List<SearchResult>> _searchInBothDatabases(String query) async {
    final trimmedQuery = query.trim();
    final strippedQuery = _stripDiacritics(trimmedQuery);

    // Step 1: Search in both databases using both original and stripped query for matching
    final List<Map<String, dynamic>> simpleResults = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'text LIKE ? OR text LIKE ?',
      whereArgs: ['%$trimmedQuery%', '%$strippedQuery%'],
      orderBy: 'surah ASC, ayah ASC',
      limit: SearchLimits.maxSearchResults,
    );

    final List<Map<String, dynamic>> scriptResults = await _imlaeiScriptDb!
        .query(
          'verses',
          columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
          where: 'text LIKE ? OR text LIKE ?',
          whereArgs: ['%$trimmedQuery%', '%$strippedQuery%'],
          orderBy: 'surah ASC, ayah ASC',
          limit: SearchLimits.maxSearchResults,
        );

    // Step 2: Filter results by stripping diacritics and checking if stripped query matches
    final List<Map<String, dynamic>> filteredSimpleResults = simpleResults
        .where((verse) {
          final strippedText = _stripDiacritics(verse['text'] as String);
          return strippedText.contains(strippedQuery);
        })
        .toList();

    final List<Map<String, dynamic>> filteredScriptResults = scriptResults
        .where((verse) {
          final strippedText = _stripDiacritics(verse['text'] as String);
          return strippedText.contains(strippedQuery);
        })
        .toList();

    // Step 3: Collect all unique verse keys from both databases
    final Set<String> allFoundVerseKeys = {};
    allFoundVerseKeys.addAll(
      filteredSimpleResults.map((v) => v['verse_key'] as String),
    );
    allFoundVerseKeys.addAll(
      filteredScriptResults.map((v) => v['verse_key'] as String),
    );

    if (allFoundVerseKeys.isEmpty) return [];

    // Step 4: Retrieve results from script database with diacritics using bulk query
    // WHY: Use bulk query with IN clause to avoid N+1 query pattern.
    // This reduces from O(N) queries to O(1) query regardless of result count.
    final List<String> verseKeysList = allFoundVerseKeys.toList();
    final placeholders = List.filled(verseKeysList.length, '?').join(', ');

    // Bulk query from script database (preferred - has diacritics)
    final List<Map<String, dynamic>> scriptVerses = await _imlaeiScriptDb!
        .query(
          'verses',
          columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
          where: 'verse_key IN ($placeholders)',
          whereArgs: verseKeysList,
          orderBy: 'surah ASC, ayah ASC',
        );

    // Build map from verse_key to verse data for O(1) lookup
    final Map<String, Map<String, dynamic>> verseMap = {};
    final Set<String> foundInScript = {};
    for (final verse in scriptVerses) {
      final verseKey = verse['verse_key'] as String?;
      if (verseKey != null) {
        verseMap[verseKey] = verse;
        foundInScript.add(verseKey);
      }
    }

    // Find verse keys not found in script database (need fallback)
    final List<String> missingFromScript = verseKeysList
        .where((key) => !foundInScript.contains(key))
        .toList();

    // Bulk query from simple database for missing verses (fallback)
    Map<String, Map<String, dynamic>> simpleVerseMap = {};
    if (missingFromScript.isNotEmpty) {
      final fallbackPlaceholders = List.filled(
        missingFromScript.length,
        '?',
      ).join(', ');
      final List<Map<String, dynamic>> simpleVerses = await _imlaeiDb!.query(
        'verses',
        columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
        where: 'verse_key IN ($fallbackPlaceholders)',
        whereArgs: missingFromScript,
        orderBy: 'surah ASC, ayah ASC',
      );

      for (final verse in simpleVerses) {
        final verseKey = verse['verse_key'] as String?;
        if (verseKey != null) {
          simpleVerseMap[verseKey] = verse;
        }
      }
    }

    // Build results using map lookups (O(1) instead of O(N) queries)
    final List<SearchResult> results = [];
    for (final verseKey in allFoundVerseKeys) {
      // Prefer script database (has diacritics), fallback to simple database
      final verseData = verseMap[verseKey] ?? simpleVerseMap[verseKey];
      if (verseData == null) continue; // Skip if not found in either database

      final String verseText = verseData['text'] as String;
      final int surahNumber = _parseInt(verseData['surah']);
      final int ayahNumber = _parseInt(verseData['ayah']);

      // Debug: Check if text contains diacritics
      if (kDebugMode && ayahNumber <= 3) {
        developer.log(
          'Verse $verseKey: Text contains diacritics = ${verseText != _stripDiacritics(verseText)}',
          name: 'SearchService',
        );
        developer.log('  Text: $verseText', name: 'SearchService');
      }

      // Get Surah name
      final String surahName = await _getSurahName(surahNumber);

      // Get page number for this verse
      final int pageNumber = await _getPageNumberForVerse(verseKey);

      // Use the verse text (prioritizing script database with diacritics)
      final String context = _highlightSearchTerm(verseText, trimmedQuery);

      results.add(
        SearchResult(
          text: trimmedQuery,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          pageNumber: pageNumber,
          surahName: surahName,
          context: context,
          wordPosition: 1, // Not applicable for verse-level search
        ),
      );
    }

    return results;
  }

  /// Get page number for a specific verse using verse_key
  Future<int> _getPageNumberForVerse(String verseKey) async {
    // Check cache first
    final cachedPage = _verseToPageCache.get(verseKey);
    if (cachedPage != null) {
      return cachedPage;
    }

    // Parse verse key (format: "1:1")
    final parts = verseKey.split(':');
    if (parts.length != 2) return 1;

    final int surahNumber = _parseInt(parts[0]);
    final int ayahNumber = _parseInt(parts[1]);

    try {
      // Use the existing DatabaseService method for accurate page mapping
      final int pageNumber = await _databaseService.getPageForAyah(
        surahNumber,
        ayahNumber,
      );
      _verseToPageCache.put(verseKey, pageNumber);
      return pageNumber;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'Error getting page for verse $verseKey',
          name: 'SearchService',
          error: e,
        );
      }
      // Fallback: return page 1
      _verseToPageCache.put(verseKey, 1);
      return 1;
    }
  }

  /// Highlight the search term in the verse text
  String _highlightSearchTerm(String verseText, String searchTerm) {
    // For now, just return the full verse text
    // In the future, we could add highlighting with special characters
    return verseText;
  }

  /// Strip Arabic diacritics from text for search matching
  String _stripDiacritics(String text) {
    // Arabic diacritics Unicode ranges
    const diacritics = [
      '\u064B', // Fathatan
      '\u064C', // Dammatan
      '\u064D', // Kasratan
      '\u064E', // Fatha
      '\u064F', // Damma
      '\u0650', // Kasra
      '\u0651', // Shadda
      '\u0652', // Sukun
      '\u0653', // Maddah
      '\u0654', // Hamza Above
      '\u0655', // Hamza Below
      '\u0656', // Subscript Alef
      '\u0657', // Inverted Damma
      '\u0658', // Mark Noon Ghunna
      '\u0659', // Zwarakay
      '\u065A', // Vowel Sign Small V Above
      '\u065B', // Vowel Sign Inverted Small V Above
      '\u065C', // Vowel Sign Dot Below
      '\u065D', // Reversed Damma
      '\u065E', // Fatha With Two Dots
      '\u065F', // Wavy Hamza Below
      '\u0670', // Superscript Alef
    ];

    String result = text;
    for (final diacritic in diacritics) {
      result = result.replaceAll(diacritic, '');
    }

    // Also normalize hamza variations
    result = result.replaceAll('أ', 'ا'); // Alif with hamza above -> alif
    result = result.replaceAll('إ', 'ا'); // Alif with hamza below -> alif
    result = result.replaceAll('آ', 'ا'); // Alif with madda -> alif

    return result;
  }

  /// Get Surah name with caching
  Future<String> _getSurahName(int surahNumber) async {
    final cachedName = _surahNameCache.get(surahNumber);
    if (cachedName != null) {
      return cachedName;
    }

    final String surahName = await _databaseService.getSurahName(surahNumber);

    _surahNameCache.put(surahNumber, surahName);
    return surahName;
  }

  /// Search by Surah name
  Future<List<SearchResult>> searchBySurahName(String surahName) async {
    await init();

    if (surahName.trim().isEmpty) return [];

    final List<Map<String, dynamic>> surahResults = await _databaseService
        .getSurahByName(surahName);

    if (surahResults.isEmpty) return [];

    final int surahNumber = _parseInt(surahResults.first[DbConstants.idCol]);

    // Get first ayah of the surah from imlaei-simple.db
    final List<Map<String, dynamic>> firstAyah = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'surah = ? AND ayah = 1',
      whereArgs: [surahNumber.toString()],
      limit: QueryLimits.singleResult,
    );

    if (firstAyah.isEmpty) return [];

    return await _buildSearchResultsFromVerses(firstAyah);
  }

  /// Search by Ayah number
  Future<List<SearchResult>> searchByAyah(
    int surahNumber,
    int ayahNumber,
  ) async {
    await init();

    final List<Map<String, dynamic>> ayahResults = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surahNumber.toString(), ayahNumber.toString()],
      limit: QueryLimits.singleResult,
    );

    return await _buildSearchResultsFromVerses(ayahResults);
  }

  /// Build SearchResult objects from verse results
  Future<List<SearchResult>> _buildSearchResultsFromVerses(
    List<Map<String, dynamic>> verseResults,
  ) async {
    final List<SearchResult> results = [];

    for (final verse in verseResults) {
      final int surahNumber = _parseInt(verse['surah']);
      final int ayahNumber = _parseInt(verse['ayah']);
      final String verseText = verse['text'] as String;
      final String verseKey = verse['verse_key'] as String;

      // Get Surah name
      final String surahName = await _getSurahName(surahNumber);

      // Get page number for this verse
      final int pageNumber = await _getPageNumberForVerse(verseKey);

      results.add(
        SearchResult(
          text: verseText,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          pageNumber: pageNumber,
          surahName: surahName,
          context: verseText,
          wordPosition: 1,
        ),
      );
    }

    return results;
  }

  /// Clear search cache
  void clearCache() {
    _searchCache.clear();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _closeDatabases();
    _searchCache.clear();
    _surahNameCache.clear();
    _verseToPageCache.clear();
    resetInitializationState();
    _currentLayout = null;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
