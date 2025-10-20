import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// --- DATABASE FILENAMES ---
const String _layoutDbFileName = 'uthmani-15-lines.db';
const String _scriptDbFileName = 'qpc-v2.db';
const String _metadataDbFileName = 'quran-metadata-surah-name.sqlite';
const String _juzDbFileName = 'quran-metadata-juz.sqlite';
const String _hizbDbFileName = 'quran-metadata-hizb.sqlite';

// --- DATA MODELS ---

class Word {
  final String text;
  Word({required this.text});
}

class LineInfo {
  final int lineNumber;
  final String lineType;
  final bool isCentered;
  final int surahNumber;
  final String? surahName;
  final List<Word> words;

  LineInfo({
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    required this.surahNumber,
    this.surahName,
    this.words = const [],
  });
}

class PageLayout {
  final int pageNumber;
  final List<LineInfo> lines;
  PageLayout({required this.pageNumber, required this.lines});
}

class PageData {
  final PageLayout layout;
  final String pageFontFamily;
  final String pageSurahName;
  final int juzNumber;
  final int hizbNumber;

  PageData({
    required this.layout,
    required this.pageFontFamily,
    required this.pageSurahName,
    required this.juzNumber,
    required this.hizbNumber,
  });
}

const String _basmallah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";

// --- FONT SERVICE ---
class FontService {
  final Map<int, String> _loadedFonts = {};

  Future<String> loadFontForPage(int pageNumber) async {
    // WHY: Use braces for consistency and lint rules.
    if (_loadedFonts.containsKey(pageNumber)) {
      return _loadedFonts[pageNumber]!;
    }

    final String pageFontFamily = 'Page$pageNumber';
    final String fontAssetPath =
        'assets/fonts/QPC V2 Font.ttf/p$pageNumber.ttf';

    try {
      final FontLoader fontLoader = FontLoader(pageFontFamily);
      fontLoader.addFont(rootBundle.load(fontAssetPath));
      await fontLoader.load();

      _loadedFonts[pageNumber] = pageFontFamily;
      return pageFontFamily;
    } catch (e) {
      throw Exception(
        "Error loading font for page $pageNumber from $fontAssetPath: $e",
      );
    }
  }
}

// --- DATABASE SERVICE ---
class DatabaseService {
  Database? _layoutDb;
  Database? _scriptDb;
  Database? _metadataDb;
  Database? _juzDb;
  Database? _hizbDb;

  List<Map<String, dynamic>> _juzCache = [];
  List<Map<String, dynamic>> _hizbCache = [];

  Future<void> _init() async {
    // WHY: Use braces for consistency and lint rules.
    if (_layoutDb != null &&
        _scriptDb != null &&
        _metadataDb != null &&
        _juzDb != null &&
        _hizbDb != null) {
      return;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    const dbAssetPath = 'assets/db';

    _layoutDb = await _initDb(
      documentsDirectory,
      dbAssetPath,
      _layoutDbFileName,
    );
    _scriptDb = await _initDb(
      documentsDirectory,
      dbAssetPath,
      _scriptDbFileName,
    );
    _metadataDb = await _initDb(
      documentsDirectory,
      dbAssetPath,
      _metadataDbFileName,
    );
    _juzDb = await _initDb(documentsDirectory, dbAssetPath, _juzDbFileName);
    _hizbDb = await _initDb(documentsDirectory, dbAssetPath, _hizbDbFileName);

    // WHY: Use braces for consistency and lint rules.
    if (_juzCache.isEmpty && _juzDb != null) {
      _juzCache = await _juzDb!.query('juz', orderBy: 'juz_number ASC');
    }
    // WHY: Use braces for consistency and lint rules.
    if (_hizbCache.isEmpty && _hizbDb != null) {
      _hizbCache = await _hizbDb!.query('hizbs', orderBy: 'hizb_number ASC');
    }
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
    // WHY: Use braces for consistency and lint rules.
    if (await dbFile.exists()) {
      return;
    }
    try {
      final ByteData data = await rootBundle.load(
        p.join('assets/db', assetFileName),
      );
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception("Error copying database '$assetFileName': $e");
    }
  }

  Future<String> getSurahName(int surahId) async {
    await _init();
    // WHY: Use braces for consistency and lint rules.
    if (_metadataDb == null) {
      throw Exception("Metadata DB not initialized.");
    }
    // WHY: Use braces for consistency and lint rules.
    if (surahId == 0) {
      return "";
    }
    try {
      final List<Map<String, dynamic>> result = await _metadataDb!.query(
        'chapters',
        columns: ['name_arabic'],
        where: 'id = ?',
        whereArgs: [surahId.toString()],
      );
      // WHY: Use braces for consistency and lint rules.
      if (result.isNotEmpty && result.first['name_arabic'] != null) {
        return result.first['name_arabic'] as String;
      }
      return 'Surah $surahId';
    } catch (e) {
      return 'Surah $surahId';
    }
  }

  int _parseInt(dynamic value) {
    // WHY: Use braces for consistency and lint rules.
    if (value == null) {
      return 0;
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<Map<String, int>> _getFirstAyahOnPage(int pageNumber) async {
    await _init();
    // WHY: Use braces for consistency and lint rules.
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized.");
    }

    final List<Map<String, dynamic>> lines = await _layoutDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: 'line_number ASC',
    );

    // WHY: Use braces for consistency and lint rules.
    if (lines.isEmpty) {
      throw Exception("No data found for page $pageNumber in layout DB.");
    }

    for (final line in lines) {
      // WHY: Use braces for consistency and lint rules.
      if (line['line_type'] == 'ayah' && line['first_word_id'] != null) {
        final firstWordId = _parseInt(line['first_word_id']);
        // WHY: Use braces for consistency and lint rules.
        if (firstWordId == 0) {
          continue;
        }

        final List<Map<String, dynamic>> words = await _scriptDb!.query(
          'words',
          columns: ['surah', 'ayah'],
          where: 'id = ?',
          whereArgs: [firstWordId.toString()],
          limit: 1,
        );
        // WHY: Use braces for consistency and lint rules.
        if (words.isNotEmpty) {
          final int surah = _parseInt(words.first['surah']);
          final int ayah = _parseInt(words.first['ayah']);
          // WHY: Use braces for consistency and lint rules.
          if (surah > 0 && ayah > 0) {
            return {'surah': surah, 'ayah': ayah};
          }
        }
      }
    }
    for (final line in lines) {
      // WHY: Use braces for consistency and lint rules.
      if (line['line_type'] == 'surah_name' && line['surah_number'] != null) {
        final int surahNum = _parseInt(line['surah_number']);
        // WHY: Use braces for consistency and lint rules.
        if (surahNum > 0) {
          return {'surah': surahNum, 'ayah': 1};
        }
      }
    }

    throw Exception(
      "Could not determine first Surah/Ayah for page $pageNumber.",
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
    // WHY: Use braces for consistency and lint rules.
    if (s < sFirst || s > sLast) {
      return false;
    }
    // WHY: Use braces for consistency and lint rules.
    if (s == sFirst && a < aFirst) {
      return false;
    }
    // WHY: Use braces for consistency and lint rules.
    if (s == sLast && a > aLast) {
      return false;
    }
    return true;
  }

  int _findJuz(int pageSurah, int pageAyah) {
    // WHY: Use braces for consistency and lint rules.
    if (_juzCache.isEmpty) {
      return 0;
    }
    for (final row in _juzCache) {
      final firstKey = row['first_verse_key'] as String?;
      final lastKey = row['last_verse_key'] as String?;

      // WHY: Use braces for consistency and lint rules.
      if (firstKey == null || lastKey == null) {
        continue;
      }

      try {
        final sFirst = _parseInt(firstKey.split(':').first);
        final aFirst = _parseInt(firstKey.split(':').last);
        final sLast = _parseInt(lastKey.split(':').first);
        final aLast = _parseInt(lastKey.split(':').last);

        // WHY: Use braces for consistency and lint rules.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return _parseInt(row['juz_number']);
        }
      } catch (_) {
        continue;
      }
    }
    return 0;
  }

  int _findHizb(int pageSurah, int pageAyah) {
    // WHY: Use braces for consistency and lint rules.
    if (_hizbCache.isEmpty) {
      return 0;
    }
    for (final row in _hizbCache) {
      final firstKey = row['first_verse_key'] as String?;
      final lastKey = row['last_verse_key'] as String?;

      // WHY: Use braces for consistency and lint rules.
      if (firstKey == null || lastKey == null) {
        continue;
      }

      try {
        final sFirst = _parseInt(firstKey.split(':').first);
        final aFirst = _parseInt(firstKey.split(':').last);
        final sLast = _parseInt(lastKey.split(':').first);
        final aLast = _parseInt(lastKey.split(':').last);

        // WHY: Use braces for consistency and lint rules.
        if (_isAyahInRange(pageSurah, pageAyah, sFirst, aFirst, sLast, aLast)) {
          return _parseInt(row['hizb_number']);
        }
      } catch (_) {
        continue;
      }
    }
    return 0;
  }

  Future<Map<String, dynamic>> getPageHeaderInfo(int pageNumber) async {
    await _init();
    try {
      final firstAyah = await _getFirstAyahOnPage(pageNumber);
      final pageSurah = firstAyah['surah']!;
      final pageAyah = firstAyah['ayah']!;

      final juzNumber = _findJuz(pageSurah, pageAyah);
      final hizbNumber = _findHizb(pageSurah, pageAyah);
      final surahName = await getSurahName(pageSurah);

      return {'juz': juzNumber, 'hizb': hizbNumber, 'surahName': surahName};
    } catch (e) {
      return {'juz': 0, 'hizb': 0, 'surahName': ''};
    }
  }

  Future<PageLayout> getPageLayout(int pageNumber) async {
    await _init();
    // WHY: Use braces for consistency and lint rules.
    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Required DBs not initialized.");
    }

    final List<Map<String, dynamic>> linesData = await _layoutDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber.toString()],
      orderBy: 'line_number ASC',
    );

    // WHY: Use braces for consistency and lint rules.
    if (linesData.isEmpty) {
      throw Exception("No layout data found for page $pageNumber.");
    }

    List<LineInfo> lines = [];
    for (var lineData in linesData) {
      final lineType = lineData['line_type'] as String;
      List<Word> words = [];
      String? surahName;

      final int surahNum = _parseInt(lineData['surah_number']);

      // WHY: Use braces for consistency and lint rules.
      if (lineType == 'ayah') {
        final firstWordId = _parseInt(lineData['first_word_id']);
        final lastWordId = _parseInt(lineData['last_word_id']);

        // WHY: Use braces for consistency and lint rules.
        if (firstWordId > 0 && lastWordId >= firstWordId) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            columns: ['text'],
            where: 'id BETWEEN ? AND ?',
            whereArgs: [firstWordId.toString(), lastWordId.toString()],
            orderBy: 'id ASC',
          );
          words = wordsData
              .map((wordMap) => Word(text: wordMap['text'] as String))
              .toList();
        } else if (firstWordId > 0 &&
            (lastWordId == 0 || lastWordId < firstWordId)) {
          final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
            'words',
            columns: ['text'],
            where: 'id = ?',
            whereArgs: [firstWordId.toString()],
            limit: 1,
          );
          words = wordsData
              .map((wordMap) => Word(text: wordMap['text'] as String))
              .toList();
        }
        // WHY: Use braces for consistency and lint rules.
      } else if (lineType == 'surah_name') {
        // WHY: Use braces for consistency and lint rules.
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

// --- STATE MANAGEMENT (RIVERPOD) ---

final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);

  await dbService._init();

  final pageFontFamilyFuture = ref
      .watch(fontServiceProvider)
      .loadFontForPage(pageNumber);
  final layoutFuture = dbService.getPageLayout(pageNumber);
  final pageHeaderInfoFuture = dbService.getPageHeaderInfo(pageNumber);

  final pageFontFamily = await pageFontFamilyFuture;
  final layout = await layoutFuture;
  final pageHeaderInfo = await pageHeaderInfoFuture;

  return PageData(
    layout: layout,
    pageFontFamily: pageFontFamily,
    pageSurahName: pageHeaderInfo['surahName'] as String,
    juzNumber: pageHeaderInfo['juz'] as int,
    hizbNumber: pageHeaderInfo['hizb'] as int,
  );
});

// --- HELPER FUNCTION ---

String convertToEasternArabicNumerals(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < western.length; i++) {
    input = input.replaceAll(western[i], eastern[i]);
  }
  return input;
}

// --- MAIN APPLICATION ---

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MushafApp()));
}

class MushafApp extends StatelessWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'QPCV2',
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MushafScreen(),
      ),
    );
  }
}

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 604,
      itemBuilder: (context, index) {
        return MushafPageWidget(pageNumber: index + 1);
      },
    );
  }
}

// --- UI WIDGETS ---

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    const headerTextStyle = TextStyle(fontSize: 14, color: Colors.black87);
    const footerTextStyle = TextStyle(fontSize: 16, color: Colors.black87);

    return asyncPageData.when(
      data: (pageData) {
        final juz = convertToEasternArabicNumerals(
          pageData.juzNumber.toString(),
        );
        final hizb = convertToEasternArabicNumerals(
          pageData.hizbNumber.toString(),
        );
        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        return Scaffold(
          appBar: AppBar(
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,

            leadingWidth: 150,
            leading: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('جزء $juz', style: headerTextStyle),
                    const SizedBox(width: 12),
                    Text('حزب $hizb', style: headerTextStyle),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(
                  child: Text(
                    pageData.pageSurahName,
                    style: headerTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 45.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: pageData.layout.lines
                      .map(
                        (line) => LineWidget(
                          line: line,
                          pageFontFamily: pageData.pageFontFamily,
                        ),
                      )
                      .toList(),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    right: 16.0,
                    left: 24.0,
                  ),
                  child: Text(pageNum, style: footerTextStyle),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load page $pageNumber.\n\nError: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class LineWidget extends StatelessWidget {
  final LineInfo line;
  final String pageFontFamily;

  const LineWidget({
    super.key,
    required this.line,
    required this.pageFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    String textToShow = '';
    TextStyle? textStyle;
    double fontSize = 21.0; // Your requested font size
    String? fontFamily = 'QPCV2';
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    switch (line.lineType) {
      case 'surah_name':
        textToShow = line.surahName ?? 'Surah';
        textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 26);
        lineAlignment = TextAlign.center;
        break;
      case 'basmallah':
        textToShow = _basmallah;
        fontSize = 20.0;
        lineAlignment = TextAlign.center;
        break;
      case 'ayah':
        textToShow = line.words.map((w) => w.text).join(' ');
        fontFamily = pageFontFamily;
        break;
      default:
        textToShow = '';
    }

    return Text(
      textToShow,
      textDirection: TextDirection.rtl,
      textAlign: lineAlignment,
      style:
          textStyle?.copyWith(
            fontFamily: fontFamily,
            fontSize: fontSize,
            height: 1.8,
          ) ??
          TextStyle(fontFamily: fontFamily, fontSize: fontSize, height: 1.8),
      textScaler: const TextScaler.linear(1.0),
    );
  }
}
