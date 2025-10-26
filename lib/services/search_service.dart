import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';

/// Service for searching Quranic text
class SearchService {
  Database? _layoutDb;
  Database? _scriptDb;
  Database? _metadataDb;
  Database? _imlaeiDb; // Database with searchable Arabic text

  // Cache for search results to improve performance
  final Map<String, List<SearchResult>> _searchCache = {};
  final Map<int, String> _surahNameCache = {};
  final Map<String, int> _verseToPageCache =
      {}; // Cache verse_key -> page_number

  bool _isInitialized = false;
  Future<void>? _initFuture;

  /// Initialize the search service with the current layout
  Future<void> init({MushafLayout layout = MushafLayout.uthmani15Lines}) async {
    if (_isInitialized) return;
    _initFuture ??= _doInit(layout);
    await _initFuture;
  }

  /// Switch to a different layout for search
  Future<void> switchLayout(MushafLayout layout) async {
    if (!_isInitialized) {
      await init(layout: layout);
      return;
    }

    // Clear caches
    _searchCache.clear();
    _surahNameCache.clear();
    _verseToPageCache.clear();

    // Close existing databases
    await _closeDatabases();

    // Reset initialization state
    _isInitialized = false;
    _initFuture = null;

    // Initialize with new layout
    await init(layout: layout);
  }

  Future<void> _doInit(MushafLayout layout) async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      const dbAssetPath = 'assets/db';

      // Initialize all databases using the same pattern as DatabaseService
      final databases = await Future.wait([
        _initDb(documentsDirectory, dbAssetPath, layout.layoutDatabaseFileName),
        _initDb(documentsDirectory, dbAssetPath, layout.scriptDatabaseFileName),
        _initDb(documentsDirectory, dbAssetPath, metadataDbFileName),
        _initDb(documentsDirectory, dbAssetPath, 'imlaei-simple.db'),
      ]);

      _layoutDb = databases[0];
      _scriptDb = databases[1];
      _metadataDb = databases[2];
      _imlaeiDb = databases[3];

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SearchService: $e');
      }
      rethrow;
    }
  }

  Future<void> _closeDatabases() async {
    await Future.wait(
      [
        _layoutDb?.close(),
        _scriptDb?.close(),
        _metadataDb?.close(),
        _imlaeiDb?.close(),
      ].where((future) => future != null).cast<Future<void>>(),
    );
    _layoutDb = null;
    _scriptDb = null;
    _metadataDb = null;
    _imlaeiDb = null;
  }

  Future<Database> _initDb(
    Directory docsDir,
    String assetPath,
    String fileName,
  ) async {
    final dbPath = p.join(docsDir.path, fileName);
    // WHY: Ensure the database file exists in the documents directory before opening.
    await _copyDbFromAssets(assetFileName: fileName, destinationPath: dbPath);
    return openDatabase(dbPath, readOnly: true);
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
    } catch (e) {
      throw Exception(
        "SearchService: Error copying database '$assetFileName' from assets: $e",
      );
    }
  }

  /// Search for Arabic text in the Quran
  Future<List<SearchResult>> searchText(String query) async {
    await init();

    if (query.trim().isEmpty) return [];

    // Check cache first
    final cacheKey = query.trim().toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    if (_imlaeiDb == null || _layoutDb == null || _metadataDb == null) {
      throw Exception('SearchService databases not initialized');
    }

    try {
      // Search in imlaei-simple.db for Arabic text
      List<SearchResult> results = await _searchInImlaeiDb(query);

      // Cache results
      _searchCache[cacheKey] = results;

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching text: $e');
      }
      return [];
    }
  }

  /// Search in imlaei-simple.db for Arabic text
  Future<List<SearchResult>> _searchInImlaeiDb(String query) async {
    final trimmedQuery = query.trim();

    // Search for verses containing the query text
    final List<Map<String, dynamic>> verseResults = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'text LIKE ?',
      whereArgs: ['%$trimmedQuery%'],
      orderBy: 'surah ASC, ayah ASC',
      limit: 100, // Limit results for performance
    );

    if (verseResults.isEmpty) return [];

    // Convert verse results to SearchResult objects
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

      // Highlight the search term in context
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
    if (_verseToPageCache.containsKey(verseKey)) {
      return _verseToPageCache[verseKey]!;
    }

    // Parse verse key (format: "1:1")
    final parts = verseKey.split(':');
    if (parts.length != 2) return 1;

    final int surahNumber = _parseInt(parts[0]);
    final int ayahNumber = _parseInt(parts[1]);

    try {
      // Use the existing DatabaseService method for accurate page mapping
      final int pageNumber = await _getPageForAyah(surahNumber, ayahNumber);
      _verseToPageCache[verseKey] = pageNumber;
      return pageNumber;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting page for verse $verseKey: $e');
      }
      // Fallback: return page 1
      _verseToPageCache[verseKey] = 1;
      return 1;
    }
  }

  /// Find the page number containing the start of a specific ayah
  Future<int> _getPageForAyah(int surahNumber, int ayahNumber) async {
    if (_scriptDb == null || _layoutDb == null) {
      throw Exception("Required DBs not initialized for _getPageForAyah.");
    }

    // 1. Find the first word ID for the given surah and ayah
    final List<Map<String, dynamic>> words = await _scriptDb!.query(
      DbConstants.wordsTable,
      columns: [DbConstants.idCol],
      where: '${DbConstants.surahCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
      whereArgs: [surahNumber.toString(), ayahNumber.toString()],
      orderBy: '${DbConstants.idCol} ASC',
      limit: 1,
    );

    if (words.isEmpty) {
      // Fallback: If ayah 1 doesn't exist, try finding page for surah start
      if (ayahNumber == 1) {
        return _getPageForSurah(surahNumber);
      }
      throw Exception(
        "SearchService: Word not found for Surah $surahNumber, Ayah $ayahNumber.",
      );
    }
    final int firstWordId = _parseInt(words.first[DbConstants.idCol]);

    // 2. Find the page layout entry containing this word ID
    final List<Map<String, dynamic>> pages = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.pageNumberCol],
      where:
          '${DbConstants.firstWordIdCol} <= ? AND ${DbConstants.lastWordIdCol} >= ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [firstWordId.toString(), firstWordId.toString(), 'ayah'],
      orderBy:
          '${DbConstants.pageNumberCol} ASC, ${DbConstants.lineNumberCol} ASC',
      limit: 1,
    );

    if (pages.isNotEmpty) {
      return _parseInt(pages.first[DbConstants.pageNumberCol]);
    }

    // Fallback: Check if it's the very first word on a line
    final List<Map<String, dynamic>> firstWordPages = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [DbConstants.pageNumberCol],
      where:
          '${DbConstants.firstWordIdCol} = ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [firstWordId.toString(), 'ayah'],
      orderBy:
          '${DbConstants.pageNumberCol} ASC, ${DbConstants.lineNumberCol} ASC',
      limit: 1,
    );

    if (firstWordPages.isNotEmpty) {
      return _parseInt(firstWordPages.first[DbConstants.pageNumberCol]);
    }

    // Final fallback specifically for Surah starts
    if (ayahNumber == 1) {
      return _getPageForSurah(surahNumber);
    }

    throw Exception(
      "SearchService: Page not found containing word ID $firstWordId (Surah $surahNumber, Ayah $ayahNumber).",
    );
  }

  /// Helper to get the starting page number for a Surah
  Future<int> _getPageForSurah(int surahNumber) async {
    if (_layoutDb == null) {
      throw Exception("Layout DB not initialized for _getPageForSurah.");
    }
    // Manually handle Surah 1 starting on page 1
    if (surahNumber == 1) return 1;

    // Try finding the page where the 'surah_name' line appears first
    final List<Map<String, dynamic>> result = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [
        'MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias}',
      ],
      where:
          '${DbConstants.surahNumberCol} = ? AND ${DbConstants.lineTypeCol} = ?',
      whereArgs: [surahNumber.toString(), 'surah_name'],
      limit: 1,
    );

    if (result.isNotEmpty && result.first[DbConstants.startPageAlias] != null) {
      return _parseInt(result.first[DbConstants.startPageAlias]);
    }
    // Broader fallback if surah_name line isn't found
    final List<Map<String, dynamic>> broaderResult = await _layoutDb!.query(
      DbConstants.pagesTable,
      columns: [
        'MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias}',
      ],
      where: '${DbConstants.surahNumberCol} = ?',
      whereArgs: [surahNumber.toString()],
      limit: 1,
    );
    if (broaderResult.isNotEmpty &&
        broaderResult.first[DbConstants.startPageAlias] != null) {
      return _parseInt(broaderResult.first[DbConstants.startPageAlias]);
    }

    throw Exception(
      "SearchService: Starting page not found for Surah $surahNumber.",
    );
  }

  /// Highlight the search term in the verse text
  String _highlightSearchTerm(String verseText, String searchTerm) {
    // For now, just return the full verse text
    // In the future, we could add highlighting with special characters
    return verseText;
  }

  /// Get Surah name with caching
  Future<String> _getSurahName(int surahNumber) async {
    if (_surahNameCache.containsKey(surahNumber)) {
      return _surahNameCache[surahNumber]!;
    }

    final List<Map<String, dynamic>> results = await _metadataDb!.query(
      DbConstants.chaptersTable,
      columns: [DbConstants.nameArabicCol],
      where: '${DbConstants.idCol} = ?',
      whereArgs: [surahNumber.toString()],
      limit: 1,
    );

    final String surahName = results.isNotEmpty
        ? results.first[DbConstants.nameArabicCol] as String
        : 'سورة $surahNumber';

    _surahNameCache[surahNumber] = surahName;
    return surahName;
  }

  /// Search by Surah name
  Future<List<SearchResult>> searchBySurahName(String surahName) async {
    await init();

    if (surahName.trim().isEmpty) return [];

    final List<Map<String, dynamic>> surahResults = await _metadataDb!.query(
      DbConstants.chaptersTable,
      columns: [DbConstants.idCol],
      where: '${DbConstants.nameArabicCol} LIKE ?',
      whereArgs: ['%$surahName%'],
    );

    if (surahResults.isEmpty) return [];

    final int surahNumber = _parseInt(surahResults.first[DbConstants.idCol]);

    // Get first ayah of the surah from imlaei-simple.db
    final List<Map<String, dynamic>> firstAyah = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'surah = ? AND ayah = 1',
      whereArgs: [surahNumber.toString()],
      limit: 1,
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
      limit: 1,
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
    _isInitialized = false;
    _initFuture = null;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
