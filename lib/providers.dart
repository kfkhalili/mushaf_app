// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';

// WHY: This directive points to the file that code-gen will create.
part 'providers.g.dart';

// --- Current Page Provider ---
// WHY: This syntax for a Notifier class is correct.
@Riverpod(keepAlive: true)
class CurrentPage extends _$CurrentPage {
  @override
  int build() {
    return 1;
  }

  void setPage(int newPage) {
    state = newPage;
  }
}

// --- Database Service Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
DatabaseService databaseService(Ref ref) {
  return DatabaseService();
}

// --- Font Loader Service Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
FontService fontService(Ref ref) {
  return FontService();
}

// --- Page Data Provider ---
// WHY: This is an auto-disposing provider (no keepAlive),
// but it *still* uses the unified 'Ref' type.
@riverpod
Future<PageData> pageData(Ref ref, int pageNumber) async {
  final dbService = ref.watch(databaseServiceProvider);
  final fontService = ref.watch(fontServiceProvider);

  String pageFontFamilyName = await fontService.loadFontForPage(pageNumber);

  final layout = await dbService.getPageLayout(pageNumber);
  final headerInfo = await dbService.getPageHeaderInfo(pageNumber);

  return PageData(
    layout: layout,
    pageFontFamily: pageFontFamilyName,
    pageSurahName: headerInfo['surahName'] as String? ?? '',
    pageSurahNumber: headerInfo['surahNumber'] as int? ?? 0,
    juzNumber: headerInfo['juz'] as int? ?? 0,
    hizbNumber: headerInfo['hizb'] as int? ?? 0,
  );
}

// --- Surah List Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
Future<List<SurahInfo>> surahList(Ref ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getAllSurahs();
}

// --- Juz List Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
Future<List<JuzInfo>> juzList(Ref ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getAllJuzInfo();
}

// --- Page Preview Provider ---
// WHY: This is an auto-disposing provider, but it
// *still* uses the unified 'Ref' type.
@riverpod
Future<String> pagePreview(Ref ref, int pageNumber) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getFirstWordsOfPage(pageNumber, count: 3);
}

// --- Page Font Family Provider ---
// WHY: This is an auto-disposing provider, but it
// *still* uses the unified 'Ref' type.
@riverpod
Future<String> pageFontFamily(Ref ref, int pageNumber) async {
  final fontService = ref.watch(fontServiceProvider);
  return fontService.loadFontForPage(pageNumber);
}
