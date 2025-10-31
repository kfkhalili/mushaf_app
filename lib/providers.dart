// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'services/search_service.dart';
import 'models.dart';
import 'constants.dart';

// WHY: This directive points to the file that code-gen will create.
part 'providers.g.dart';

// --- Shared Preferences Provider ---
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

// (UI signals moved to utils/ui_signals.dart to avoid codegen dependencies.)

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
// WHY: Lightweight provider for list view previews (DB-only, no font loading or full layout).
@riverpod
Future<String> pagePreview(Ref ref, int pageNumber) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getFirstWordsOfPage(pageNumber, count: 3);
}

// --- Page Font Family Provider ---
// WHY: Returns font family name for a page without loading full layout. For list previews.
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
// WHY: This provider automatically sets font size to maximum for each layout.
@Riverpod(keepAlive: true)
class FontSizeSetting extends _$FontSizeSetting {
  @override
  double build() {
    final layout = ref.watch(mushafLayoutSettingProvider);
    return layoutMaxFontSizes[layout] ?? 20.0;
  }
}

// --- Search Service Provider ---
@Riverpod(keepAlive: true)
SearchService searchService(Ref ref) {
  final layout = ref.watch(mushafLayoutSettingProvider);
  final service = SearchService();
  service.init(layout: layout);
  return service;
}

// --- Search Query Provider ---
@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query.trim();
  }

  void clearQuery() {
    state = '';
  }
}

// --- Search Results Provider ---
@riverpod
Future<List<SearchResult>> searchResults(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];

  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchText(query);
}

// (Removed) BreathWordsSetting: UI removed and no remaining references

// --- Search History Provider ---
@Riverpod(keepAlive: true)
class SearchHistory extends _$SearchHistory {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 20;

  @override
  List<String> build() {
    final prefs = ref.read(sharedPreferencesProvider).value;
    final historyJson = prefs?.getStringList(_searchHistoryKey) ?? [];
    return historyJson.take(_maxHistoryItems).toList();
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();
    final currentHistory = List<String>.from(state);

    // Remove if already exists
    currentHistory.remove(trimmedQuery);

    // Add to beginning
    currentHistory.insert(0, trimmedQuery);

    // Limit to max items
    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
    }

    state = currentHistory;

    // Save to preferences
    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.setStringList(_searchHistoryKey, currentHistory);
  }

  void clearHistory() {
    state = [];
    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.remove(_searchHistoryKey);
  }

  void removeFromHistory(String query) {
    final currentHistory = List<String>.from(state);
    currentHistory.remove(query);
    state = currentHistory;

    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.setStringList(_searchHistoryKey, currentHistory);
  }
}
