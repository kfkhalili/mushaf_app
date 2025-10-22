import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for print
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';

class DatabaseService {
  Database? _layoutDb;
  Database? _scriptDb;
  Database? _metadataDb;
  Database? _juzDb;
  Database? _hizbDb;

  List<Map<String, dynamic>> _juzCache = [];
  List<Map<String, dynamic>> _hizbCache = [];

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    const dbAssetPath = 'assets/db';

    final databases = await Future.wait([
      _initDb(documentsDirectory, dbAssetPath, layoutDbFileName),
      _initDb(documentsDirectory, dbAssetPath, scriptDbFileName),
      _initDb(documentsDirectory, dbAssetPath, metadataDbFileName),
      _initDb(documentsDirectory, dbAssetPath, juzDbFileName),
      _initDb(documentsDirectory, dbAssetPath, hizbDbFileName),
    ]);

    _layoutDb = databases[0];
    _scriptDb = databases[1];
    _metadataDb = databases[2];
    _juzDb = databases[3];
    _hizbDb = databases[4];

    // WHY: Load Juz and Hizb data into cache upon initialization for faster lookups later.
    if (_juzCache.isEmpty && _juzDb != null) {
      _juzCache = await _juzDb!.query('juz', orderBy: 'juz_number ASC');
    }
    if (_hizbCache.isEmpty && _hizbDb != null) {
      _hizbCache = await _hizbDb!.query('hizbs', orderBy: 'hizb_number ASC');
    }

    _isInitialized = true;
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
        "DatabaseService: Error copying database '$assetFileName' from assets: $e",
      );
    }
  }

  /// Fetches all surahs with their names, revelation place, and starting page.
  Future<List<SurahInfo>> getAllSurahs() async {
    await init(); // Ensure initialization
    if (_metadataDb == null || _layoutDb == null) {
      throw Exception(
        "Required databases for getAllSurahs are not initialized.",
      );
    }

    // 1. Get all Surah metadata
    final List<Map<String, dynamic>> chapters = await _metadataDb!.query(
      'chapters',
      orderBy: 'id ASC',
    );

    // 2. Get the starting page for each Surah (earliest page where surah_number appears).
    final List<Map<String, dynamic>>
    surahStartPages = await _layoutDb!.rawQuery(
      'SELECT surah_number, MIN(page_number) as start_page FROM pages WHERE surah_number > 0 GROUP BY surah_number',
    );

    // 3. Create a quick lookup map for page numbers (Surah Number -> Start Page).
    final Map<int, int> pageMap = {
      for (var row in surahStartPages)
        _parseInt(row['surah_number']): _parseInt(row['start_page']),
    };
    // WHY: Surah Al-Fatiha starts on page 1, which might not be picked up by the query if page 1 layout doesn't explicitly list surah_number 1.
    pageMap[1] = 1;

    // 4. Combine the data into a list of SurahInfo objects.
    return chapters.map((chapter) {
      final int surahNum = _parseInt(chapter['id']);
      return SurahInfo(
        surahNumber: surahNum,
        nameArabic: chapter['name_arabic'] as String,
        revelationPlace: chapter['revelation_place'] as String,
        startingPage: pageMap[surahNum] ?? 0, // Default to 0 if not found
      );
    }).toList();
  }

  /// Retrieves the Arabic name of a Surah given its ID (1-114).
  Future<String> getSurahName(int surahId) async {
    await init();
    if (_metadataDb == null) throw Exception("Metadata DB not initialized.");
    if (surahId <= 0 || surahId > 114) return ""; // Handle invalid IDs

    try {
      final List<Map<String, dynamic>> result = await _metadataDb!.query(
        'chapters',
        columns: ['name_arabic'],
        where: 'id = ?',
        whereArgs: [surahId.toString()],
        limit: 1,
      );
      if (result.isNotEmpty && result.first['name_arabic'] != null) {
        return result.first['name_arabic'] as String;
      }
      return 'Surah $surahId'; // Fallback name
    } catch (e) {
      return 'Surah $surahId'; // Fallback on error
    }
  }

  /// Safely parses an integer from a dynamic value.
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Determines the first Surah and Ayah number that appears on a given page.
  Future<Map<String, int>> _getFirstAyahOnPage(int pageNumber) async {
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized for _getFirstAyahOnPage.");
    }

    // Get all layout lines for the page, ordered.
    final List<Map<String, dynamic>> lines = await _layoutDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: 'line_number ASC',
    );

    if (lines.isEmpty) {
      throw Exception(
        "DatabaseService: No layout data found for page $pageNumber.",
      );
    }

    // WHY: Iterate through lines to find the first 'ayah' line with a valid word ID.
    for (final line in lines) {
      if (line['line_type'] == 'ayah' && line['first_word_id'] != null) {
        final firstWordId = _parseInt(line['first_word_id']);
        if (firstWordId == 0) continue; // Skip if ID is invalid

        // Query the script DB to get the Surah/Ayah for this word ID.
        final List<Map<String, dynamic>> words = await _scriptDb!.query(
          'words',
          columns: ['surah', 'ayah'],
          where: 'id = ?',
          whereArgs: [firstWordId.toString()],
          limit: 1,
        );
        if (words.isNotEmpty) {
          final int surah = _parseInt(words.first['surah']);
          final int ayah = _parseInt(words.first['ayah']);
          if (surah > 0 && ayah > 0) {
            return {'surah': surah, 'ayah': ayah}; // Found it
          }
        }
      }
    }
    // WHY: Fallback if no 'ayah' line found (e.g., page starts exactly with a Surah name).
    for (final line in lines) {
      if (line['line_type'] == 'surah_name' && line['surah_number'] != null) {
        final int surahNum = _parseInt(line['surah_number']);
        if (surahNum > 0) {
          return {'surah': surahNum, 'ayah': 1}; // Assume Ayah 1
        }
      }
    }

    // Should not happen with valid data, but throw if no Surah/Ayah found.
    throw Exception(
      "DatabaseService: Could not determine first Surah/Ayah for page $pageNumber.",
    );
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
      final firstKey = row['first_verse_key'] as String?;
      final lastKey = row['last_verse_key'] as String?;
      if (firstKey == null || lastKey == null) continue; // Skip invalid data

      try {
        // Parse the start and end Surah:Ayah keys.
        final sFirst = _parseInt(firstKey.split(':').first);
        final aFirst = _parseInt(firstKey.split(':').last);
        final sLast = _parseInt(lastKey.split(':').first);
        final aLast = _parseInt(lastKey.split(':').last);
        // Check if the target ayah falls within this Juz' range.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return _parseInt(row['juz_number']); // Found it
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
      final firstKey = row['first_verse_key'] as String?;
      final lastKey = row['last_verse_key'] as String?;
      if (firstKey == null || lastKey == null) continue; // Skip invalid data

      try {
        // Parse the start and end Surah:Ayah keys.
        final sFirst = _parseInt(firstKey.split(':').first);
        final aFirst = _parseInt(firstKey.split(':').last);
        final sLast = _parseInt(lastKey.split(':').first);
        final aLast = _parseInt(lastKey.split(':').last);
        // Check if the target ayah falls within this Hizb range.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return _parseInt(row['hizb_number']); // Found it
        }
      } catch (_) {
        continue; // Ignore errors parsing keys
      }
    }
    return 0; // Not found
  }

  /// Retrieves header information (Juz', Hizb, Surah Name, Surah Number) for a given page.
  Future<Map<String, dynamic>> getPageHeaderInfo(int pageNumber) async {
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
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized for getPageLayout.");
    }

    // Get all layout lines for the page.
    final List<Map<String, dynamic>> linesData = await _layoutDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: 'line_number ASC',
    );

    if (linesData.isEmpty) {
      throw Exception(
        "DatabaseService: No layout data found for page $pageNumber.",
      );
    }

    List<LineInfo> lines = [];
    // Process each line to fetch words or surah name.
    for (var lineData in linesData) {
      final lineType = lineData['line_type'] as String;
      List<Word> words = [];
      String? surahName;
      final int surahNum = _parseInt(lineData['surah_number']);

      if (lineType == 'ayah') {
        final firstWordId = _parseInt(lineData['first_word_id']);
        final lastWordId = _parseInt(lineData['last_word_id']);

        // Fetch words within the ID range for this line.
        if (firstWordId > 0 && lastWordId >= firstWordId) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            // WHY: Include surah and ayah for each word, needed for memorization logic.
            columns: ['text', 'surah', 'ayah'],
            where: 'id BETWEEN ? AND ?',
            whereArgs: [firstWordId.toString(), lastWordId.toString()],
            orderBy: 'id ASC',
          );
          words = wordsData.map((wordMap) {
            return Word(
              text: wordMap['text'] as String,
              surahNumber: _parseInt(wordMap['surah']),
              ayahNumber: _parseInt(wordMap['ayah']),
            );
          }).toList();
        }
        // Handle lines with only one word.
        else if (firstWordId > 0 &&
            (lastWordId == 0 || lastWordId < firstWordId)) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            columns: ['text', 'surah', 'ayah'],
            where: 'id = ?',
            whereArgs: [firstWordId.toString()],
            limit: 1,
          );
          words = wordsData.map((wordMap) {
            return Word(
              text: wordMap['text'] as String,
              surahNumber: _parseInt(wordMap['surah']),
              ayahNumber: _parseInt(wordMap['ayah']),
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
          lineNumber: _parseInt(lineData['line_number']),
          isCentered: _parseInt(lineData['is_centered']) == 1,
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

  /// Finds the page number containing the start of a specific ayah.
  Future<int> getPageForAyah(int surahNumber, int ayahNumber) async {
    await init();
    if (_scriptDb == null || _layoutDb == null) {
      throw Exception("Required DBs not initialized for getPageForAyah.");
    }

    // 1. Find the first word ID for the given surah and ayah.
    final List<Map<String, dynamic>> words = await _scriptDb!.query(
      'words',
      columns: ['id'],
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surahNumber.toString(), ayahNumber.toString()],
      orderBy: 'id ASC',
      limit: 1,
    );

    if (words.isEmpty) {
      // Fallback: If ayah 1 doesn't exist (e.g., invalid input), try finding page for surah start
      if (ayahNumber == 1) {
        return getPageForSurah(surahNumber);
      }
      throw Exception(
        "DatabaseService: Word not found for Surah $surahNumber, Ayah $ayahNumber.",
      );
    }
    final int firstWordId = _parseInt(words.first['id']);

    // 2. Find the page layout entry containing this word ID.
    // Check if the word ID falls within the first_word_id and last_word_id range.
    final List<Map<String, dynamic>> pages = await _layoutDb!.query(
      'pages',
      columns: ['page_number'],
      where: 'first_word_id <= ? AND last_word_id >= ? AND line_type = ?',
      whereArgs: [firstWordId.toString(), firstWordId.toString(), 'ayah'],
      orderBy:
          'page_number ASC, line_number ASC', // Ensure the earliest occurrence
      limit: 1,
    );

    if (pages.isNotEmpty) {
      return _parseInt(pages.first['page_number']);
    }

    // Fallback: Check if it's the very first word on a line (last_word_id might be 0 or equal)
    final List<Map<String, dynamic>> firstWordPages = await _layoutDb!.query(
      'pages',
      columns: ['page_number'],
      where: 'first_word_id = ? AND line_type = ?',
      whereArgs: [firstWordId.toString(), 'ayah'],
      orderBy: 'page_number ASC, line_number ASC',
      limit: 1,
    );

    if (firstWordPages.isNotEmpty) {
      return _parseInt(firstWordPages.first['page_number']);
    }

    // Final fallback specifically for Surah starts (like Surah 1 page 1)
    if (ayahNumber == 1) {
      return getPageForSurah(surahNumber);
    }

    throw Exception(
      "DatabaseService: Page not found containing word ID $firstWordId (Surah $surahNumber, Ayah $ayahNumber).",
    );
  }

  /// Helper to get the starting page number for a Surah.
  Future<int> getPageForSurah(int surahNumber) async {
    await init();
    if (_layoutDb == null) {
      throw Exception("Layout DB not initialized for getPageForSurah.");
    }
    // Manually handle Surah 1 starting on page 1
    if (surahNumber == 1) return 1;

    // Try finding the page where the 'surah_name' line appears first.
    final List<Map<String, dynamic>> result = await _layoutDb!.query(
      'pages',
      columns: ['MIN(page_number) as start_page'],
      where: 'surah_number = ? AND line_type = ?',
      whereArgs: [surahNumber.toString(), 'surah_name'],
      limit: 1,
    );

    if (result.isNotEmpty && result.first['start_page'] != null) {
      return _parseInt(result.first['start_page']);
    }
    // Broader fallback if surah_name line isn't found (look for any line with that surah_number).
    final List<Map<String, dynamic>> broaderResult = await _layoutDb!.query(
      'pages',
      columns: ['MIN(page_number) as start_page'],
      where: 'surah_number = ?',
      whereArgs: [surahNumber.toString()],
      limit: 1,
    );
    if (broaderResult.isNotEmpty && broaderResult.first['start_page'] != null) {
      return _parseInt(broaderResult.first['start_page']);
    }

    throw Exception(
      "DatabaseService: Starting page not found for Surah $surahNumber.",
    );
  }

  /// Retrieves information (number and starting page) for all 30 Juz'.
  Future<List<JuzInfo>> getAllJuzInfo() async {
    await init();
    if (_juzCache.isEmpty) {
      throw Exception("Juz' data cache is empty or not initialized.");
    }

    List<JuzInfo> juzList = [];
    // Process each Juz' entry from the cache.
    for (final juzData in _juzCache) {
      final int juzNum = _parseInt(juzData['juz_number']);
      final String? firstVerseKey = juzData['first_verse_key'] as String?;

      if (firstVerseKey != null && firstVerseKey.isNotEmpty) {
        try {
          // Parse Surah:Ayah from the key.
          final parts = firstVerseKey.split(':');
          if (parts.length == 2) {
            final int surah = _parseInt(parts[0]);
            final int ayah = _parseInt(parts[1]);
            if (surah > 0 && ayah > 0) {
              // Find the page number for the starting ayah of this Juz'.
              final int startPage = await getPageForAyah(surah, ayah);
              juzList.add(JuzInfo(juzNumber: juzNum, startingPage: startPage));
            } else {
              // Log warning for invalid keys but continue processing others.
              if (kDebugMode) {
                print(
                  "Warning: Invalid verse key '$firstVerseKey' for Juz $juzNum",
                );
              }
            }
          }
        } catch (e) {
          // Log errors during processing but continue.
          if (kDebugMode) {
            print("Error processing Juz $juzNum start page lookup: $e");
          }
        }
      }
    }
    // Return the list of successfully processed Juz' info.
    return juzList;
  }
}
