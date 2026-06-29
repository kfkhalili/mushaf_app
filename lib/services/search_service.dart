import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/lru_cache.dart';
import '../utils/parsing_helpers.dart';
import '../utils/validation_helpers.dart';
import '../utils/rate_limiter.dart';
import 'bundled_database_store.dart';
import 'database_store.dart';
import 'database_service.dart';

/// Service for searching Quranic text
class SearchService with InitializationMixin {
  final DatabaseService _databaseService;
  Database? _imlaeiDb; // Database with searchable Arabic text
  Database? _imlaeiScriptDb; // Database with ayah-by-ayah script text

  // WHY: Use LRU caches to limit memory usage and prevent unbounded growth.
  // Evicts least recently used items when cache is full.
  final LRUCache<String, SearchOutcome> _searchCache =
      LRUCache<String, SearchOutcome>(SearchCacheLimits.maxSearchCacheSize);
  final LRUCache<int, String> _surahNameCache = LRUCache<int, String>(
    SearchCacheLimits.maxSurahNameCacheSize,
  );
  final LRUCache<String, int> _verseToPageCache = LRUCache<String, int>(
    SearchCacheLimits.maxVerseToPageCacheSize,
  ); // Cache verse_key -> page_number

  MushafLayout? _currentLayout;

  // WHY: Loads + opens the bundled search databases. Injectable so tests can
  // substitute a store that opens fixtures instead of bundled assets.
  final DatabaseStore _store;

  SearchService(
    this._databaseService, {
    DatabaseStore store = const BundledDatabaseStore(),
  }) : _store = store;

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
      // WHY: Same databases regardless of layout (search is layout-agnostic).
      final databases = await Future.wait([
        _store.open(imlaeiSimpleDbFileName),
        _store.open(imlaeiAyahDbFileName),
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

  /// Search for Arabic text in the Quran. Returns the matches plus a flag
  /// indicating whether more matches existed than were returned (the result set
  /// is capped at [SearchLimits.maxSearchResults]).
  Future<SearchOutcome> searchText(String query) async {
    await init();

    // Check rate limit before processing
    // WHY: Defense in depth - prevent DoS attacks with rapid search requests
    if (!SearchRateLimiter.canMakeRequest()) {
      if (kDebugMode) {
        developer.log(
          'Search rate limit exceeded. Remaining: ${SearchRateLimiter.remainingRequests}',
          name: 'SearchService',
        );
      }
      // Return empty results instead of throwing to provide graceful degradation
      return const SearchOutcome(results: []);
    }

    // Validate and sanitize search query
    try {
      final sanitizedQuery = validateSearchQuery(query);
      // Use sanitized query for search
      query = sanitizedQuery;
    } on ArgumentError catch (e) {
      if (kDebugMode) {
        developer.log('Invalid search query: $e', name: 'SearchService');
      }
      return const SearchOutcome(results: []);
    }

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
      final (List<SearchResult> results, bool truncated) =
          await _searchInBothDatabases(query);
      final outcome = SearchOutcome(results: results, isTruncated: truncated);

      // Cache results
      _searchCache.put(cacheKey, outcome);

      return outcome;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error searching text', name: 'SearchService', error: e);
      }
      return const SearchOutcome(results: []);
    }
  }

  /// Search in both imlaei databases and combine results without duplicates.
  /// Returns the (deduped, capped) results and whether more matches existed.
  Future<(List<SearchResult>, bool)> _searchInBothDatabases(
    String query,
  ) async {
    final trimmedQuery = query.trim();
    final strippedQuery = _stripDiacritics(trimmedQuery);

    // Step 1: Search in both databases using both original and stripped query for matching
    final List<Map<String, dynamic>> simpleResults = await _imlaeiDb!.query(
      'verses',
      columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
      where: 'text LIKE ? OR text LIKE ?',
      whereArgs: ['%$trimmedQuery%', '%$strippedQuery%'],
      orderBy: 'surah ASC, ayah ASC',
      // WHY: maxSearchResults + 1 so a full page tells us more matches exist
      // than we return, letting the UI flag truncation instead of hiding it.
      limit: SearchLimits.maxSearchResults + 1,
    );

    final List<Map<String, dynamic>> scriptResults = await _imlaeiScriptDb!
        .query(
          'verses',
          columns: ['id', 'verse_key', 'surah', 'ayah', 'text'],
          where: 'text LIKE ? OR text LIKE ?',
          whereArgs: ['%$trimmedQuery%', '%$strippedQuery%'],
          orderBy: 'surah ASC, ayah ASC',
          limit: SearchLimits.maxSearchResults + 1,
        );

    // True when either source returned a full over-limit page — more matches
    // exist than this result set will contain.
    final bool truncated =
        simpleResults.length > SearchLimits.maxSearchResults ||
        scriptResults.length > SearchLimits.maxSearchResults;

    // Step 2: Filter results by stripping diacritics and checking if stripped query matches
    final List<Map<String, dynamic>> filteredSimpleResults = simpleResults
        .where((verse) {
          // Use nullable cast and check for null
          // WHY: Type safety - database data may be corrupted
          final String? verseText = verse['text'] as String?;
          if (verseText == null) return false;
          final strippedText = _stripDiacritics(verseText);
          return strippedText.contains(strippedQuery);
        })
        .toList();

    final List<Map<String, dynamic>> filteredScriptResults = scriptResults
        .where((verse) {
          // Use nullable cast and check for null
          // WHY: Type safety - database data may be corrupted
          final String? verseText = verse['text'] as String?;
          if (verseText == null) return false;
          final strippedText = _stripDiacritics(verseText);
          return strippedText.contains(strippedQuery);
        })
        .toList();

    // Step 3: Collect all unique verse keys from both databases
    final Set<String> allFoundVerseKeys = {};
    allFoundVerseKeys.addAll(
      filteredSimpleResults
          .map((v) => v['verse_key'] as String?)
          .whereType<String>(), // Filter out null values
    );
    allFoundVerseKeys.addAll(
      filteredScriptResults
          .map((v) => v['verse_key'] as String?)
          .whereType<String>(), // Filter out null values
    );

    if (allFoundVerseKeys.isEmpty) return (<SearchResult>[], false);

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

      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted or schema may change
      final String? verseText = verseData['text'] as String?;
      if (verseText == null) {
        if (kDebugMode) {
          developer.log(
            'Missing verse text in search result: $verseKey',
            name: 'SearchService',
          );
        }
        continue; // Skip invalid entries
      }

      final int surahNumber = parseInt(verseData['surah']);
      final int ayahNumber = parseInt(verseData['ayah']);

      // Validate parsed surah/ayah numbers before use
      // WHY: Defense in depth - validate even trusted database data
      try {
        validateSurahNumber(surahNumber);
        validateAyahNumber(ayahNumber);
      } catch (e) {
        // Skip invalid entries - database data may be corrupted
        if (kDebugMode) {
          developer.log(
            'Invalid surah/ayah in search result: $surahNumber:$ayahNumber',
            name: 'SearchService',
          );
        }
        continue;
      }

      // Debug: Check if text contains diacritics
      if (kDebugMode && ayahNumber <= 3) {
        developer.log(
          'Verse $verseKey: Text contains diacritics = ${verseText != _stripDiacritics(verseText)}',
          name: 'SearchService',
        );
        developer.log('  Text: $verseText', name: 'SearchService');
      }

      // Get page number for this verse; skip results we cannot place rather
      // than defaulting them to page 1.
      final int? pageNumber = await _getPageNumberForVerse(verseKey);
      if (pageNumber == null) {
        continue;
      }

      // Get Surah name - safe to use validated surahNumber
      final String surahName = await _getSurahName(surahNumber);

      // Use the verse text (prioritizing script database with diacritics)
      final String context = verseText;

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

    // Cap the deduped set to the limit; flag truncation if either the raw query
    // overflowed or the dedup union itself exceeded the cap.
    if (results.length > SearchLimits.maxSearchResults) {
      return (results.sublist(0, SearchLimits.maxSearchResults), true);
    }
    return (results, truncated);
  }

  /// Resolves the page number for a verse from its `verse_key`, or `null` when
  /// it cannot be determined — a malformed key, an out-of-range surah/ayah, or a
  /// database error. Callers skip unplaceable results rather than sending the
  /// user to page 1, which previously masked corruption as a valid hit.
  Future<int?> _getPageNumberForVerse(String verseKey) async {
    // Check cache first
    final cachedPage = _verseToPageCache.get(verseKey);
    if (cachedPage != null) {
      return cachedPage;
    }

    // Parse verse key (format: "1:1")
    // WHY: Validate split results before parsing
    final parts = verseKey.split(':');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return null; // Malformed verse key — cannot place
    }

    final int surahNumber = parseInt(parts[0]);
    final int ayahNumber = parseInt(parts[1]);

    // Validate parsed surah/ayah numbers before use
    // WHY: Defense in depth - validate parsed values before operations
    try {
      validateSurahNumber(surahNumber);
      validateAyahNumber(ayahNumber);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Invalid verse key: $verseKey', name: 'SearchService');
      }
      return null; // Out of range — cannot place
    }

    try {
      // Use the existing DatabaseService method for accurate page mapping
      // Safe to use validated surahNumber and ayahNumber
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
      // WHY: Do NOT cache a guessed page — a transient DB error must not poison
      // the cache with a wrong mapping. Return null so the caller skips it.
      return null;
    }
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

    // Validate and sanitize surah name query
    try {
      final sanitizedQuery = validateSearchQuery(surahName);
      surahName = sanitizedQuery;
    } on ArgumentError catch (e) {
      if (kDebugMode) {
        developer.log('Invalid surah name query: $e', name: 'SearchService');
      }
      return [];
    }

    final List<Map<String, dynamic>> surahResults = await _databaseService
        .getSurahByName(surahName);

    if (surahResults.isEmpty) return [];

    final int surahNumber = parseInt(surahResults.first[DbConstants.idCol]);

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
      final int surahNumber = parseInt(verse['surah']);
      final int ayahNumber = parseInt(verse['ayah']);

      // Validate parsed surah/ayah numbers before use
      // WHY: Defense in depth - validate even trusted database data
      try {
        validateSurahNumber(surahNumber);
        validateAyahNumber(ayahNumber);
      } catch (e) {
        // Skip invalid entries - database data may be corrupted
        if (kDebugMode) {
          developer.log(
            'Invalid surah/ayah in search result: $surahNumber:$ayahNumber',
            name: 'SearchService',
          );
        }
        continue;
      }

      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted
      final String? verseText = verse['text'] as String?;
      final String? verseKey = verse['verse_key'] as String?;
      if (verseText == null || verseKey == null) {
        if (kDebugMode) {
          developer.log(
            'Missing verse text or key in search result',
            name: 'SearchService',
          );
        }
        continue; // Skip invalid entries
      }

      // Get page number for this verse; skip results we cannot place rather
      // than defaulting them to page 1.
      final int? pageNumber = await _getPageNumberForVerse(verseKey);
      if (pageNumber == null) {
        continue;
      }

      // Get Surah name - safe to use validated surahNumber
      final String surahName = await _getSurahName(surahNumber);

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

  // WHY: Use shared parsing utility instead of duplicate method
  // Removed parseInt() - use parseInt() from parsing_helpers.dart
}
