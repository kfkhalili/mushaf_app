import 'dart:async';
import 'package:flutter/foundation.dart'; // For kDebugMode and debugPrint
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/parsing_helpers.dart';
import '../utils/validation_helpers.dart';
import 'bundled_database_store.dart';
import 'juz_hizb_index.dart';
import 'audio_metadata.dart';

class DatabaseService with InitializationMixin {
  Database? _layoutDb;
  Database? _scriptDb;
  Database? _metadataDb;
  Database? _ayahTextDb;

  // WHY: Layout-independent Juz'/Hizb range lookups live behind their own
  // module; built once and reused across layout switches.
  JuzHizbIndex? _juzHizbIndex;

  MushafLayout? _currentLayout;

  // WHY: Page counts are layout-specific (604 / 849 / 1890). Cached once at init
  // from the layout's `info` table so page-number validation is accurate per
  // layout instead of relying on a hardcoded 604 ceiling.
  int? _totalPages;

  // WHY: Loads + opens bundled read-only databases. Injectable so tests can
  // substitute a store that opens fixtures instead of bundled assets.
  final BundledDatabaseStore _store;

  // WHY: Recitation audio metadata is the only user of the audio database; it
  // lives behind its own module that owns that connection.
  final AudioMetadata _audioMetadata;

  DatabaseService({BundledDatabaseStore store = const BundledDatabaseStore()})
    : _store = store,
      _audioMetadata = AudioMetadata(store: store);

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

    final databases = await Future.wait([
      _store.open(layout.layoutDatabaseFileName),
      _store.open(layout.scriptDatabaseFileName),
      _store.open(metadataDbFileName),
      _store.open(imlaeiAyahDbFileName),
    ]);

    _layoutDb = databases[0];
    _scriptDb = databases[1];
    _metadataDb = databases[2];
    _ayahTextDb = databases[3];

    // WHY: Cache the layout's page count once so validatePageNumber() can bound
    // against the real per-layout total (not a hardcoded 604). Falls back to the
    // generic ceiling if the info table is missing/unreadable.
    try {
      final List<Map<String, dynamic>> infoResult = await _layoutDb!.query(
        DbConstants.infoTable,
        columns: [DbConstants.numberOfPagesCol],
        limit: QueryLimits.singleResult,
      );
      if (infoResult.isNotEmpty &&
          infoResult.first[DbConstants.numberOfPagesCol] != null) {
        _totalPages = parseInt(infoResult.first[DbConstants.numberOfPagesCol]);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not cache total pages from info table: $e');
      }
      _totalPages = null;
    }

    // WHY: Audio metadata and the Juz'/Hizb index own their own connections.
    // JuzHizbIndex opens its two databases just long enough to read their range
    // tables; AudioMetadata keeps the audio connection open for runtime queries.
    await _audioMetadata.init();
    _juzHizbIndex ??= await JuzHizbIndex.load(_store);

    markInitialized();
  }

  Future<void> close() async {
    await _closeDatabases();
    resetInitializationState();
    _currentLayout = null;
  }

  Future<void> _closeDatabases() async {
    _totalPages = null;
    await _audioMetadata.close();
    await Future.wait(
      [
        _layoutDb?.close(),
        _scriptDb?.close(),
        _metadataDb?.close(),
        _ayahTextDb?.close(),
      ].where((future) => future != null).cast<Future<void>>(),
    );
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

  /// Retrieves all words for a specific ayah from the script database.
  /// This returns words with layout-specific glyphs (Uthmani) or text (Indopak).
  Future<List<Word>> getWordsForAyah(int surahNumber, int ayahNumber) async {
    // Validate input parameters
    validateSurahAyah(surahNumber, ayahNumber);

    await init();
    if (_scriptDb == null) {
      throw DatabaseNotInitializedException(
        "Script database is not initialized",
      );
    }

    try {
      final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
        DbConstants.wordsTable,
        columns: [
          DbConstants.textCol,
          DbConstants.surahCol,
          DbConstants.ayahNumberCol,
        ],
        where:
            '${DbConstants.surahCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surahNumber.toString(), ayahNumber.toString()],
        orderBy: '${DbConstants.idCol} ASC',
      );

      return wordsData.map((wordMap) {
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "Error fetching words for ayah $surahNumber:$ayahNumber: $e",
        );
        // TODO: Include stackTrace when implementing crash analytics
        // catch (e, stackTrace) { ... debugPrint(stackTrace.toString()); }
      }
      return []; // Return empty list on error
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
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);
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
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);

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

  /// Retrieves header information (Juz', Hizb, Surah Name, Surah Number) for a given page.
  Future<Map<String, dynamic>> getPageHeaderInfo(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);

    await init();
    try {
      // Find the first ayah on the page to determine context.
      final firstAyah = await _getFirstAyahOnPage(pageNumber);
      final pageSurah = firstAyah['surah']!;
      final pageAyah = firstAyah['ayah']!;

      // Use the Juz'/Hizb index for cached range lookups.
      final juzNumber = _juzHizbIndex?.juzForAyah(pageSurah, pageAyah) ?? 0;
      final hizbNumber = _juzHizbIndex?.hizbForAyah(pageSurah, pageAyah) ?? 0;
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
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);

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
    return _audioMetadata.surahAudio(surahNumber);
  }

  /// Gets segment information for a specific ayah.
  Future<AyahSegment?> getAyahSegment(int surahNumber, int ayahNumber) async {
    await init();
    return _audioMetadata.ayahSegment(surahNumber, ayahNumber);
  }

  /// Gets all segments for a specific surah.
  Future<List<AyahSegment>> getSurahSegments(int surahNumber) async {
    await init();
    return _audioMetadata.surahSegments(surahNumber);
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
    if (_juzHizbIndex == null) {
      throw DatabaseNotInitializedException("Juz' index is not initialized");
    }

    final List<JuzInfo> juzList = [];
    // Resolve each Juz' starting page from its (validated) starting ayah.
    for (final start in _juzHizbIndex!.juzStarts()) {
      try {
        final int startPage = await getPageForAyah(start.surah, start.ayah);
        juzList.add(
          JuzInfo(juzNumber: start.juzNumber, startingPage: startPage),
        );
      } catch (e) {
        // Log errors during processing but continue.
        if (kDebugMode) {
          debugPrint(
            "Error processing Juz ${start.juzNumber} start page lookup: $e",
          );
        }
      }
    }
    return juzList;
  }

  /// Gets the last ayah on a specific page.
  Future<Map<String, int>?> getLastAyahOnPage(int pageNumber) async {
    // Validate input parameter
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);

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

  /// Gets the last ayah number in a specific surah — i.e. its ayah count.
  ///
  /// WHY: Sourced from the surah metadata (`verses_count`), not the recitation
  /// segments. The ayah count is an intrinsic property of the surah and must
  /// not depend on whether audio exists for it (the old segment-based lookup
  /// returned null for any surah lacking recitation data).
  Future<int?> getLastAyahInSurah(int surahNumber) async {
    try {
      validateSurahNumber(surahNumber);
    } catch (_) {
      return null;
    }

    await init();
    if (_metadataDb == null) {
      throw DatabaseNotInitializedException(
        "Metadata database is not initialized",
      );
    }

    try {
      final List<Map<String, dynamic>> result = await _metadataDb!.query(
        DbConstants.chaptersTable,
        columns: [DbConstants.versesCountCol],
        where: '${DbConstants.idCol} = ?',
        whereArgs: [surahNumber.toString()],
        limit: QueryLimits.singleResult,
      );
      if (result.isEmpty) return null;

      final int count = parseInt(result.first[DbConstants.versesCountCol]);
      return count > 0 ? count : null;
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
    final end = _juzHizbIndex?.lastAyahInJuz(juzNumber);
    if (end == null) return null;
    return {'surah': end.surah, 'ayah': end.ayah};
  }

  /// Gets the juz number for a specific surah and ayah.
  Future<int?> getJuzForAyah(int surahNumber, int ayahNumber) async {
    await init();
    final juzNumber = _juzHizbIndex?.juzForAyah(surahNumber, ayahNumber) ?? 0;
    return juzNumber > 0 ? juzNumber : null;
  }

  /// Retrieves the total number of pages for the current layout.
  ///
  /// Returns the count cached at init from the layout database's
  /// `info.number_of_pages` — the real per-layout total (Uthmani 604,
  /// Indopak 849, Indopak 9-line 1890). Throws [DatabaseNotFoundException] if
  /// that value was missing/unreadable (a corrupt bundled database) rather than
  /// silently returning a wrong hardcoded default that breaks non-Uthmani
  /// layouts. Callers either surface the error or fall back to the generic
  /// [validatePageNumber] ceiling.
  Future<int> getTotalPages() async {
    await init();
    final int? cached = _totalPages;
    if (cached != null) return cached;
    throw DatabaseNotFoundException(
      'number_of_pages unavailable in layout info table',
    );
  }

  /// Reads the active layout's authored `font_name` from the info table.
  ///
  /// WHY: This is the data the font/script registry is keyed on
  /// (see [mushafFontRegistry]); a test cross-checks [mushafLayoutFontName]
  /// against it so the hardcoded mirror can't drift from the databases.
  Future<String?> getLayoutFontName() async {
    await init();
    if (_layoutDb == null) {
      throw DatabaseNotInitializedException(
        "Layout database is not initialized for getLayoutFontName",
      );
    }
    final List<Map<String, dynamic>> result = await _layoutDb!.query(
      DbConstants.infoTable,
      columns: [DbConstants.fontNameCol],
      limit: QueryLimits.singleResult,
    );
    if (result.isEmpty) return null;
    return result.first[DbConstants.fontNameCol] as String?;
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
      switch (_currentLayout) {
        case MushafLayout.indopak13Lines:
          return const LayoutInfo(name: 'Indopak', linesPerPage: 13);
        case MushafLayout.digitalKhatt15Lines:
          return const LayoutInfo(name: 'Digital Khatt', linesPerPage: 15);
        case MushafLayout.indopak9Lines:
          return const LayoutInfo(name: 'Indopak 9 lines', linesPerPage: 9);
        case MushafLayout.uthmani15Lines:
        default:
          return const LayoutInfo(name: 'Uthmani Hafs', linesPerPage: 15);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error retrieving layout info from database: $e');
      }
      // Fallback on error
      switch (_currentLayout) {
        case MushafLayout.indopak13Lines:
          return const LayoutInfo(name: 'Indopak', linesPerPage: 13);
        case MushafLayout.digitalKhatt15Lines:
          return const LayoutInfo(name: 'Digital Khatt', linesPerPage: 15);
        case MushafLayout.indopak9Lines:
          return const LayoutInfo(name: 'Indopak 9 lines', linesPerPage: 9);
        case MushafLayout.uthmani15Lines:
        default:
          return const LayoutInfo(name: 'Uthmani Hafs', linesPerPage: 15);
      }
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
      final db = await _store.open(layout.layoutDatabaseFileName);

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
    switch (layout) {
      case MushafLayout.indopak13Lines:
        return const LayoutInfo(name: 'Indopak', linesPerPage: 13);
      case MushafLayout.digitalKhatt15Lines:
        return const LayoutInfo(name: 'Digital Khatt', linesPerPage: 15);
      case MushafLayout.indopak9Lines:
        return const LayoutInfo(name: 'Indopak 9 lines', linesPerPage: 9);
      case MushafLayout.uthmani15Lines:
        return const LayoutInfo(name: 'Uthmani Hafs', linesPerPage: 15);
    }
  }

  /// Retrieves the text of the first 'count' words appearing on a specific page.
  Future<String> getFirstWordsOfPage(int pageNumber, {int count = 3}) async {
    // Validate input parameter
    validatePageNumber(pageNumber, maxPage: _totalPages ?? totalPages);

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
