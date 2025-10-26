// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';
import 'constants.dart';

// WHY: This directive points to the file that code-gen will create.
part 'providers.g.dart';

// --- Shared Preferences Provider ---
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

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
// WHY: This is a keepAlive provider for managing font size preference per layout.
@Riverpod(keepAlive: true)
class FontSizeSetting extends _$FontSizeSetting {
  static const String _fontSizeKeyPrefix = 'font_size_';

  @override
  double build() {
    final layout = ref.watch(mushafLayoutSettingProvider);
    return _getFontSizeForLayout(layout);
  }

  double _getFontSizeForLayout(MushafLayout layout) {
    final prefs = ref.read(sharedPreferencesProvider).value;
    final key = '$_fontSizeKeyPrefix${layout.name}';
    final savedSize = prefs?.getDouble(key);

    if (savedSize != null) {
      final layoutOptions = layoutFontSizeOptions[layout] ?? [16.0, 18.0, 20.0];
      final minSize = layoutOptions.first;
      final maxSize = layoutOptions.last;

      // Return saved size if it's within valid range, otherwise use default
      if (savedSize >= minSize && savedSize <= maxSize) {
        return savedSize;
      }
    }

    // Return layout-specific default if no valid saved size
    return layoutDefaultFontSizes[layout] ?? 18.0;
  }

  void setFontSize(double fontSize) {
    final layout = ref.read(mushafLayoutSettingProvider);
    final layoutOptions = layoutFontSizeOptions[layout] ?? [16.0, 18.0, 20.0];

    // Clamp font size to layout-specific valid range
    final minSize = layoutOptions.first;
    final maxSize = layoutOptions.last;
    final clampedSize = fontSize.clamp(minSize, maxSize);

    // Save to preferences
    final prefs = ref.read(sharedPreferencesProvider).value;
    final key = '$_fontSizeKeyPrefix${layout.name}';
    prefs?.setDouble(key, clampedSize);

    state = clampedSize;
  }

  void increaseFontSize() {
    final layout = ref.read(mushafLayoutSettingProvider);
    final layoutOptions = layoutFontSizeOptions[layout] ?? [16.0, 18.0, 20.0];
    final currentIndex = layoutOptions.indexOf(state);

    if (currentIndex < layoutOptions.length - 1) {
      setFontSize(layoutOptions[currentIndex + 1]);
    }
  }

  void decreaseFontSize() {
    final layout = ref.read(mushafLayoutSettingProvider);
    final layoutOptions = layoutFontSizeOptions[layout] ?? [16.0, 18.0, 20.0];
    final currentIndex = layoutOptions.indexOf(state);

    if (currentIndex > 0) {
      setFontSize(layoutOptions[currentIndex - 1]);
    }
  }
}
