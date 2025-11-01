// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'services/search_service.dart';
import 'services/bookmarks_service.dart';
import 'services/reading_progress_service.dart';
import 'models.dart';
import 'constants.dart';
import 'memorization/models.dart';
import 'services/memorization_service.dart';
import 'services/memorization_storage.dart';

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
  DatabaseService? _service;

  @override
  Future<DatabaseService> build() async {
    // When the provider is rebuilt (e.g., due to layout change),
    // close the old database connections before creating a new service.
    await _service?.close();

    final layout = ref.watch(mushafLayoutSettingProvider);
    _service = DatabaseService();
    await _service!.init(layout: layout);

    // Ensure the database connections are closed when the provider is disposed.
    ref.onDispose(() async {
      await _service?.close();
      _service = null;
    });

    return _service!;
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
  final dbServiceAsync = ref.watch(databaseServiceProvider);

  // Handle loading and error states for the async database service
  return dbServiceAsync.when(
    data: (dbService) async {
      final fontService = ref.watch(fontServiceProvider);
      final layout = ref.watch(mushafLayoutSettingProvider);

      final pageFontFamilyName = await fontService.loadFontForPage(
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
    },
    loading: () => Future.value(PageData.loading()), // Return a loading state
    error: (error, stack) => throw error, // Propagate error to be handled by UI
  );
}

// --- Surah List Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
Future<List<SurahInfo>> surahList(Ref ref) async {
  final dbService = await ref.watch(databaseServiceProvider.future);
  return dbService.getAllSurahs();
}

// --- Juz List Provider ---
// WHY: All provider functions now use the unified 'Ref' type.
@Riverpod(keepAlive: true)
Future<List<JuzInfo>> juzList(Ref ref) async {
  final dbService = await ref.watch(databaseServiceProvider.future);
  return dbService.getAllJuzInfo();
}

// --- Page Preview Provider ---
// WHY: Lightweight provider for list view previews (DB-only, no font loading or full layout).
@riverpod
Future<String> pagePreview(Ref ref, int pageNumber) async {
  final dbService = await ref.watch(databaseServiceProvider.future);
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
    return 0; // Default to Surah tab (index 0: Surah=0, Juz=1, Pages=2)
  }

  void setTabIndex(int index) {
    // Clamp index to valid range (0-2)
    if (index >= 0 && index <= 2) {
      state = index;
    }
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
Future<SearchService> searchService(Ref ref) async {
  final layout = ref.watch(mushafLayoutSettingProvider);
  final dbService = await ref.watch(databaseServiceProvider.future);
  final service = SearchService(dbService);
  await service.init(layout: layout);
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

  final searchService = await ref.watch(searchServiceProvider.future);
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

// --- Bookmarks Service Provider ---
@Riverpod(keepAlive: true)
Future<BookmarksService> bookmarksService(Ref ref) async {
  final dbService = await ref.watch(databaseServiceProvider.future);
  return SqliteBookmarksService(dbService);
}

// --- Bookmarks List Provider --- (Removed - using Bookmarks notifier instead)

// --- Is Ayah Bookmarked Provider ---
@riverpod
Future<bool> isAyahBookmarked(Ref ref, int surahNumber, int ayahNumber) async {
  final service = await ref.watch(bookmarksServiceProvider.future);
  return service.isBookmarked(surahNumber, ayahNumber);
}

// --- Bookmarks Notifier ---
@Riverpod(keepAlive: true)
class BookmarksNotifier extends _$BookmarksNotifier {
  @override
  Future<List<Bookmark>> build() async {
    final service = await ref.watch(bookmarksServiceProvider.future);
    return service.getAllBookmarks();
  }

  // Toggle bookmark for specific ayah
  Future<void> toggleAyahBookmark(int surahNumber, int ayahNumber) async {
    final service = await ref.read(bookmarksServiceProvider.future);
    final isBookmarked = await service.isBookmarked(surahNumber, ayahNumber);

    if (isBookmarked) {
      await service.removeBookmark(surahNumber, ayahNumber);
    } else {
      await service.addBookmark(surahNumber, ayahNumber);
    }

    // Invalidate to refresh list
    ref.invalidateSelf();
    ref.invalidate(isAyahBookmarkedProvider(surahNumber, ayahNumber));
  }

  // Remove bookmark by surah:ayah
  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final service = await ref.read(bookmarksServiceProvider.future);

    // Optimistically update the UI to remove the bookmark instantly.
    final previousState = await future;
    state = AsyncValue.data(
      previousState
          .where(
            (b) =>
                !(b.surahNumber == surahNumber && b.ayahNumber == ayahNumber),
          )
          .toList(),
    );

    try {
      // Perform the actual deletion from the database.
      await service.removeBookmark(surahNumber, ayahNumber);
      // Invalidate the provider that checks if a specific ayah is bookmarked.
      ref.invalidate(isAyahBookmarkedProvider(surahNumber, ayahNumber));
    } catch (e) {
      // If the deletion fails, revert the state to show the bookmark again.
      state = AsyncValue.data(previousState);
      // Optionally, you could show an error message to the user here.
    }
  }
}

// --- Bookmark Page Number Provider ---
// Provider for getting page number for a bookmark's ayah in current layout
@riverpod
Future<int?> bookmarkPageNumber(
  Ref ref,
  int surahNumber,
  int ayahNumber,
) async {
  try {
    final dbService = await ref.watch(databaseServiceProvider.future);
    return await dbService.getPageForAyah(surahNumber, ayahNumber);
  } catch (e) {
    return null;
  }
}

// --- Reading Progress Service Provider ---
@Riverpod(keepAlive: true)
ReadingProgressService readingProgressService(Ref ref) {
  return SqliteReadingProgressService();
}

// --- Reading Statistics Provider ---
@riverpod
Future<ReadingStatistics> readingStatistics(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getStatistics();
}

// --- Pages Read Today Provider ---
@riverpod
Future<int> pagesReadToday(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getPagesReadToday();
}

// --- Current Streak Provider ---
@riverpod
Future<int> currentStreak(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getCurrentStreak();
}

// --- Theme Mode Enum ---
// WHY: Defined here for centralized provider management
enum AppThemeMode { light, dark, sepia, system }

// --- Theme Provider ---
// WHY: Migrated from legacy StateNotifier to codegen @riverpod pattern
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  AppThemeMode build() {
    // Default state - initial value will be loaded synchronously from SharedPreferences
    // For now, return system as default (main.dart will override with actual value)
    return AppThemeMode.system;
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    // Save to SharedPreferences using provider
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString('theme_mode', mode.name);
    } catch (e) {
      // Handle potential errors, e.g., if storage is unavailable
    }
  }
}

// --- Memorization Session Provider ---
// WHY: Migrated from legacy StateNotifier to codegen @riverpod pattern
@Riverpod(keepAlive: true)
class MemorizationSessionNotifier extends _$MemorizationSessionNotifier {
  @override
  MemorizationSessionState? build() {
    return null;
  }

  final MemorizationService _service = const MemorizationService();
  late final MemorizationStorage _storage = InMemoryMemorizationStorage();
  MemorizationConfig _config = const MemorizationConfig();

  void setConfig(MemorizationConfig config) {
    _config = config;
  }

  Future<void> resumeIfExists(int pageNumber) async {
    final loaded = await _storage.loadSession(pageNumber);
    if (loaded != null) {
      state = loaded;
    }
  }

  Future<void> startSession({
    required int pageNumber,
    required int firstAyahIndex,
  }) async {
    state = MemorizationSessionState(
      pageNumber: pageNumber,
      window: AyahWindowState(
        ayahIndices: [firstAyahIndex],
        opacities: const [1.0],
        tapsSinceReveal: const [0],
      ),
      lastAyahIndexShown: firstAyahIndex,
      lastUpdatedAt: DateTime.now(),
      passCount: 0,
    );
    await _maybePersist();
  }

  bool get isActive => state != null;

  Future<void> endSession() async {
    final page = state?.pageNumber;
    state = null;
    if (page != null) {
      await _storage.clearSession(page);
    }
  }

  Future<void> onTap({required int totalAyatOnPage}) async {
    if (state == null) return;

    final next = _service.applyTap(
      state: state!,
      config: _config,
      totalAyatOnPage: totalAyatOnPage,
    );

    state = next;
    await _maybePersist();
  }

  Future<void> _maybePersist() async {
    if (state == null) return;
    await _storage.saveSession(state!);
  }
}
