// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';
import 'constants.dart';

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
// WHY: This is a keepAlive provider for managing database operations with layout switching.
@Riverpod(keepAlive: true)
class DatabaseServiceNotifier extends _$DatabaseServiceNotifier {
  @override
  DatabaseService build() {
    final layout = ref.watch(mushafLayoutSettingProvider);
    final service = DatabaseService();
    service.init(layout: layout);
    return service;
  }

  // WHY: Method to switch layout and reinitialize database service
  Future<void> switchLayout(MushafLayout layout) async {
    await state.switchLayout(layout);
    ref.invalidateSelf();
  }
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
  final layout = ref.watch(mushafLayoutSettingProvider);

  String pageFontFamilyName = await fontService.loadFontForPage(
    pageNumber,
    layout: layout,
  );

  final layoutData = await dbService.getPageLayout(pageNumber);
  final headerInfo = await dbService.getPageHeaderInfo(pageNumber);

  return PageData(
    layout: layoutData,
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
  final layout = ref.watch(mushafLayoutSettingProvider);
  return fontService.loadFontForPage(pageNumber, layout: layout);
}

// --- Navigation Provider ---
// WHY: This is a keepAlive provider for managing selection screen tab state.
@Riverpod(keepAlive: true)
class SelectionTabIndex extends _$SelectionTabIndex {
  @override
  int build() {
    return 2; // Default to Surah tab
  }

  void setTabIndex(int index) {
    state = index;
  }
}

// --- Mushaf Layout Provider ---
// WHY: This is a keepAlive provider for managing mushaf layout preference.
@Riverpod(keepAlive: true)
class MushafLayoutSetting extends _$MushafLayoutSetting {
  @override
  MushafLayout build() {
    return MushafLayout.uthmani15Lines; // Default to 15 lines
  }

  void setLayout(MushafLayout layout) {
    state = layout;
  }
}

// --- Font Size Provider ---
// WHY: This is a keepAlive provider for managing font size preference.
@Riverpod(keepAlive: true)
class FontSizeSetting extends _$FontSizeSetting {
  @override
  double build() {
    return defaultFontSize; // Default font size
  }

  void setFontSize(double fontSize) {
    // Clamp font size to valid range
    state = fontSize.clamp(minFontSize, maxFontSize);
  }

  void increaseFontSize() {
    setFontSize(state + fontSizeStep);
  }

  void decreaseFontSize() {
    setFontSize(state - fontSizeStep);
  }
}
