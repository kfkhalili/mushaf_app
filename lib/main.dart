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
  PageData({required this.layout, required this.pageFontFamily});
}

// CORRECTED: The Basmallah string now uses the correct Arabic characters.
const String _basmallah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";

// --- FONT SERVICE ---
class FontService {
  final Map<int, String> _loadedFonts = {};

  Future<String> loadFontForPage(int pageNumber) async {
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

  Future<void> _init() async {
    if (_layoutDb != null && _scriptDb != null && _metadataDb != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final layoutDbPath = p.join(documentsDirectory.path, _layoutDbFileName);
    await _copyDbFromAssets(
      assetFileName: _layoutDbFileName,
      destinationPath: layoutDbPath,
    );
    _layoutDb = await openDatabase(layoutDbPath, readOnly: true);

    final scriptDbPath = p.join(documentsDirectory.path, _scriptDbFileName);
    await _copyDbFromAssets(
      assetFileName: _scriptDbFileName,
      destinationPath: scriptDbPath,
    );
    _scriptDb = await openDatabase(scriptDbPath, readOnly: true);

    final metadataDbPath = p.join(documentsDirectory.path, _metadataDbFileName);
    await _copyDbFromAssets(
      assetFileName: _metadataDbFileName,
      destinationPath: metadataDbPath,
    );
    _metadataDb = await openDatabase(metadataDbPath, readOnly: true);
  }

  Future<void> _copyDbFromAssets({
    required String assetFileName,
    required String destinationPath,
  }) async {
    final dbFile = File(destinationPath);
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
    if (_metadataDb == null) throw Exception("Metadata DB not initialized.");

    try {
      final List<Map<String, dynamic>> result = await _metadataDb!.query(
        'chapters',
        columns: ['name_arabic'],
        where: 'id = ?',
        whereArgs: [surahId],
      );
      if (result.isNotEmpty) {
        return result.first['name_arabic'] as String;
      }
      return 'Surah $surahId';
    } catch (e) {
      throw Exception("Error querying 'chapters' table for Surah $surahId: $e");
    }
  }

  Future<PageLayout> getPageLayout(int pageNumber) async {
    await _init();

    if (_layoutDb == null || _scriptDb == null) {
      throw Exception("Databases are not initialized.");
    }

    final List<Map<String, dynamic>> linesData = await _layoutDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      orderBy: 'line_number ASC',
    );

    List<LineInfo> lines = [];
    for (var lineData in linesData) {
      final lineType = lineData['line_type'] as String;
      List<Word> words = [];
      String? surahName;

      final int surahNum =
          int.tryParse(lineData['surah_number'].toString()) ?? 0;

      if (lineType == 'ayah') {
        final firstWordId = int.parse(lineData['first_word_id'].toString());
        final lastWordId = int.parse(lineData['last_word_id'].toString());

        final List<Map<String, dynamic>> wordsData = await _scriptDb!.query(
          'words',
          columns: ['text'],
          where: 'id BETWEEN ? AND ?',
          whereArgs: [firstWordId, lastWordId],
          orderBy: 'id ASC',
        );

        words = wordsData
            .map((wordMap) => Word(text: wordMap['text']))
            .toList();
      } else if (lineType == 'surah_name') {
        if (surahNum > 0) {
          surahName = await getSurahName(surahNum);
        }
      }

      lines.add(
        LineInfo(
          lineNumber: int.parse(lineData['line_number'].toString()),
          isCentered: (int.parse(lineData['is_centered'].toString())) == 1,
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
  final pageFontFamily = await ref
      .watch(fontServiceProvider)
      .loadFontForPage(pageNumber);
  final layout = await ref
      .watch(databaseServiceProvider)
      .getPageLayout(pageNumber);
  return PageData(layout: layout, pageFontFamily: pageFontFamily);
});

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
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'QPCV2'),
      home: const MushafScreen(),
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
  int _currentPage = 1;

  @override
  void initState() {
    // CORRECTED: The syntax error is fixed.
    super.initState();
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page $_currentPage'), centerTitle: true),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 604,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page + 1;
          });
        },
        itemBuilder: (context, index) {
          return MushafPageWidget(pageNumber: index + 1);
        },
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: asyncPageData.when(
        data: (pageData) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pageData.layout.lines
              .map(
                (line) => LineWidget(
                  line: line,
                  pageFontFamily: pageData.pageFontFamily,
                ),
              )
              .toList(),
        ),
        loading: () => Center(child: Text("Loading Page $pageNumber...")),
        error: (err, stack) => Center(
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
    double fontSize = 24.0;
    String? fontFamily = 'QPCV2';

    switch (line.lineType) {
      case 'surah_name':
        textToShow = line.surahName ?? 'Surah';
        textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
        break;
      case 'basmallah':
        textToShow = _basmallah;
        fontSize = 22.0;
        break;
      case 'ayah':
        textToShow = line.words.map((w) => w.text).join(' ');
        fontFamily = pageFontFamily;
        break;
      default:
        textToShow = '';
    }

    return Align(
      alignment: line.isCentered ? Alignment.center : Alignment.centerRight,
      child: Text(
        textToShow,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style:
            textStyle?.copyWith(fontFamily: fontFamily, fontSize: fontSize) ??
            TextStyle(fontFamily: fontFamily, fontSize: fontSize),
        textScaler: const TextScaler.linear(1.1),
      ),
    );
  }
}
