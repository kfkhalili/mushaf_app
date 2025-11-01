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
import 'database_service.dart';

/// Service for searching Quranic text
class SearchService {
  final DatabaseService _databaseService;
  Database? _imlaeiDb; // Database with searchable Arabic text
  Database? _imlaeiScriptDb; // Database with ayah-by-ayah script text

  // Cache for search results to improve performance
  final Map<String, List<SearchResult>> _searchCache = {};
  final Map<int, String> _surahNameCache = {};
  final Map<String, int> _verseToPageCache =
      {}; // Cache verse_key -> page_number

  bool _isInitialized = false;
  Future<void>? _initFuture;

  SearchService(this._databaseService);

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
        _initDb(documentsDirectory, dbAssetPath, 'imlaei-simple.db'),
        _initDb(
          documentsDirectory,
          dbAssetPath,
          'imlaei-script-ayah-by-ayah.db',
        ),
      ]);

      _imlaeiDb = databases[0];
      _imlaeiScriptDb = databases[1];

      _isInitialized = true;
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

    if (_imlaeiDb == null || _imlaeiScriptDb == null) {
      throw Exception('SearchService databases not initialized');
    }

    try {
      // Search in both databases and combine results without duplicates
      List<SearchResult> results = await _searchInBothDatabases(query);

      // Cache results
      _searchCache[cacheKey] = results;

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
      limit: 100,
    );

    final List<Map<String, dynamic>> scriptResults = await _imlaeiScriptDb!
        .query(
          'verses',
          columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
          where: 'text LIKE ? OR text LIKE ?',
          whereArgs: ['%$trimmedQuery%', '%$strippedQuery%'],
          orderBy: 'surah ASC, ayah ASC',
          limit: 100,
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

    // Step 4: Retrieve results from script database with diacritics
    final List<SearchResult> results = [];

    for (final verseKey in allFoundVerseKeys) {
      // Try to get the original diacritical text from script database
      final List<Map<String, dynamic>> scriptVerse = await _imlaeiScriptDb!
          .query(
            'verses',
            columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
            where: 'verse_key = ?',
            whereArgs: [verseKey],
            limit: 1,
          );

      String verseText;
      int surahNumber;
      int ayahNumber;

      if (scriptVerse.isNotEmpty) {
        // Use script database text (with diacritics)
        final verseData = scriptVerse.first;
        verseText = verseData['text'] as String;
        surahNumber = _parseInt(verseData['surah']);
        ayahNumber = _parseInt(verseData['ayah']);
      } else {
        // Fallback to simple database if not found in script database
        final List<Map<String, dynamic>> simpleVerse = await _imlaeiDb!.query(
          'verses',
          columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
          where: 'verse_key = ?',
          whereArgs: [verseKey],
          limit: 1,
        );

        if (simpleVerse.isEmpty) continue;

        final verseData = simpleVerse.first;
        verseText = verseData['text'] as String;
        surahNumber = _parseInt(verseData['surah']);
        ayahNumber = _parseInt(verseData['ayah']);
      }

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
      final int pageNumber = await _databaseService.getPageForAyah(
        surahNumber,
        ayahNumber,
      );
      _verseToPageCache[verseKey] = pageNumber;
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
      _verseToPageCache[verseKey] = 1;
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
    if (_surahNameCache.containsKey(surahNumber)) {
      return _surahNameCache[surahNumber]!;
    }

    final String surahName = await _databaseService.getSurahName(surahNumber);

    _surahNameCache[surahNumber] = surahName;
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
