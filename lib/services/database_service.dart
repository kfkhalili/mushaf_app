import 'dart:io';
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

  List<Map<String, dynamic>> _juzCache = [];

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

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

    if (_juzCache.isEmpty && _juzDb != null) {
      _juzCache = await _juzDb!.query('juz', orderBy: 'juz_number ASC');
    }

    _isInitialized = true;
  }

  Future<Database> _initDb(
    Directory docsDir,
    String assetPath,
    String fileName,
  ) async {
    final dbPath = p.join(docsDir.path, fileName);
    await _copyDbFromAssets(assetFileName: fileName, destinationPath: dbPath);
    return openDatabase(dbPath, readOnly: true);
  }

  Future<void> _copyDbFromAssets({
    required String assetFileName,
    required String destinationPath,
  }) async {
    final dbFile = File(destinationPath);
    if (await dbFile.exists()) return;
    try {
      final ByteData data = await rootBundle.load(
        p.join('assets/db', assetFileName),
      );
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.parent.create(recursive: true);
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception(
        "DatabaseService: Error copying database '$assetFileName': $e",
      );
    }
  }

  /// Fetches a map of "surah:ayah" keys to a list of word IDs for a page.
  Future<Map<String, List<int>>> getAyahWordMapForPage(int pageNumber) async {
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception(
        "Required DBs not initialized for getAyahWordMapForPage.",
      );
    }

    final List<Map<String, dynamic>> pageBounds = await _layoutDb!.rawQuery(
      'SELECT MIN(CAST(first_word_id AS INT)) as min_id, MAX(CAST(last_word_id AS INT)) as max_id FROM pages WHERE page_number = ? AND line_type = "ayah"',
      [pageNumber.toString()],
    );

    if (pageBounds.isEmpty || pageBounds.first['min_id'] == null) return {};

    final int firstWordIdOnPage = _parseInt(pageBounds.first['min_id']);
    final int lastWordIdOnPage = _parseInt(pageBounds.first['max_id']);

    if (firstWordIdOnPage == 0 || lastWordIdOnPage == 0) return {};

    final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
      'words',
      columns: ['id', 'surah', 'ayah'],
      where: 'id BETWEEN ? AND ?',
      whereArgs: [firstWordIdOnPage.toString(), lastWordIdOnPage.toString()],
      orderBy: 'id ASC',
    );

    final Map<String, List<int>> ayahsMap = {};

    for (final wordRow in wordsData) {
      final String ayahKey = '${wordRow['surah']}:${wordRow['ayah']}';
      if (!ayahsMap.containsKey(ayahKey)) {
        ayahsMap[ayahKey] = [];
      }
      ayahsMap[ayahKey]!.add(_parseInt(wordRow['id']));
    }

    return ayahsMap;
  }

  // ... (getAllSurahs, getSurahName, _parseInt, etc. remain the same)
  Future<List<SurahInfo>> getAllSurahs() async {
    await init();
    if (_metadataDb == null || _layoutDb == null) {
      throw Exception(
        "Required databases for getAllSurahs are not initialized.",
      );
    }

    final List<Map<String, dynamic>> chapters = await _metadataDb!.query(
      'chapters',
      orderBy: 'id ASC',
    );

    final List<Map<String, dynamic>>
    surahStartPages = await _layoutDb!.rawQuery(
      'SELECT surah_number, MIN(CAST(page_number AS INT)) as start_page FROM pages WHERE surah_number > 0 GROUP BY surah_number',
    );

    final Map<int, int> pageMap = {
      for (var row in surahStartPages)
        _parseInt(row['surah_number']): _parseInt(row['start_page']),
    };
    pageMap[1] = 1;

    return chapters.map((chapter) {
      final int surahNum = _parseInt(chapter['id']);
      return SurahInfo(
        surahNumber: surahNum,
        nameArabic: chapter['name_arabic'] as String,
        revelationPlace: chapter['revelation_place'] as String,
        startingPage: pageMap[surahNum] ?? 0,
      );
    }).toList();
  }

  Future<String> getSurahName(int surahId) async {
    await init();
    if (_metadataDb == null) throw Exception("Metadata DB not initialized.");
    if (surahId <= 0 || surahId > 114) return "";

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
      return 'Surah $surahId';
    } catch (e) {
      return 'Surah $surahId';
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<Map<String, int>> _getFirstAyahOnPage(int pageNumber) async {
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized.");
    }

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

    for (final line in lines) {
      if (line['line_type'] == 'ayah' && line['first_word_id'] != null) {
        final firstWordId = _parseInt(line['first_word_id']);
        if (firstWordId == 0) continue;

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
            return {'surah': surah, 'ayah': ayah};
          }
        }
      }
    }
    for (final line in lines) {
      if (line['line_type'] == 'surah_name' && line['surah_number'] != null) {
        final int surahNum = _parseInt(line['surah_number']);
        if (surahNum > 0) {
          return {'surah': surahNum, 'ayah': 1};
        }
      }
    }

    throw Exception(
      "DatabaseService: Could not determine first Surah/Ayah for page $pageNumber.",
    );
  }

  bool _isAyahInRange(
    int s,
    int a,
    int sFirst,
    int aFirst,
    int sLast,
    int aLast,
  ) {
    if (s < sFirst || s > sLast) return false;
    if (s == sFirst && a < aFirst) return false;
    if (s == sLast && a > aLast) return false;
    return true;
  }

  int _findJuz(int pageSurah, int pageAyah) {
    if (_juzCache.isEmpty) return 0;
    for (final row in _juzCache) {
      final firstKey = row['first_verse_key'] as String?;
      final lastKey = row['last_verse_key'] as String?;
      if (firstKey == null || lastKey == null) continue;

      try {
        final sFirst = _parseInt(firstKey.split(':').first);
        final aFirst = _parseInt(firstKey.split(':').last);
        final sLast = _parseInt(lastKey.split(':').first);
        final aLast = _parseInt(lastKey.split(':').last);
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return _parseInt(row['juz_number']);
        }
      } catch (_) {
        continue;
      }
    }
    return 0;
  }

  Future<Map<String, dynamic>> getPageHeaderInfo(int pageNumber) async {
    await init();
    try {
      final firstAyah = await _getFirstAyahOnPage(pageNumber);
      final pageSurah = firstAyah['surah']!;
      final pageAyah = firstAyah['ayah']!;

      final juzNumber = _findJuz(pageSurah, pageAyah);
      final surahName = (pageSurah > 0) ? await getSurahName(pageSurah) : "";

      return {
        'juz': juzNumber,
        'surahName': surahName,
        'surahNumber': pageSurah,
      };
    } catch (e) {
      return {'juz': 0, 'surahName': '', 'surahNumber': 0};
    }
  }

  Future<PageLayout> getPageLayout(int pageNumber) async {
    await init();
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized.");
    }

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
    for (var lineData in linesData) {
      final lineType = lineData['line_type'] as String;
      List<Word> words = [];
      String? surahName;

      final int surahNum = _parseInt(lineData['surah_number']);

      if (lineType == 'ayah') {
        final firstWordId = _parseInt(lineData['first_word_id']);
        final lastWordId = _parseInt(lineData['last_word_id']);

        if (firstWordId > 0 && lastWordId >= firstWordId) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            columns: ['id', 'text'], // Fetch 'id'
            where: 'id BETWEEN ? AND ?',
            whereArgs: [firstWordId.toString(), lastWordId.toString()],
            orderBy: 'id ASC',
          );
          words = wordsData
              .map(
                (wordMap) => Word(
                  id: _parseInt(wordMap['id']),
                  text: wordMap['text'] as String,
                ),
              )
              .toList();
        } else if (firstWordId > 0 &&
            (lastWordId == 0 || lastWordId < firstWordId)) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            columns: ['id', 'text'], // Fetch 'id'
            where: 'id = ?',
            whereArgs: [firstWordId.toString()],
            limit: 1,
          );
          words = wordsData
              .map(
                (wordMap) => Word(
                  id: _parseInt(wordMap['id']),
                  text: wordMap['text'] as String,
                ),
              )
              .toList();
        }
      } else if (lineType == 'surah_name') {
        if (surahNum > 0) {
          surahName = await getSurahName(surahNum);
        }
      }

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
    return PageLayout(pageNumber: pageNumber, lines: lines);
  }
}
