// lib/providers.dart

// WHY: These are the only two imports you need for this file.
// 'riverpod_annotation' provides the @riverpod annotation and the 'Ref' type.
import 'dart:async';
import 'package:flutter/foundation.dart'; // For kDebugMode and debugPrint
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'services/search_service.dart';
import 'services/bookmarks_service.dart';
import 'services/reading_progress_service.dart';
import 'services/app_data_service.dart';
import 'services/memorization_storage.dart';
import 'services/memorization_storage_sqlite.dart';
import 'services/ontology_service.dart';
import 'services/audio_service.dart';
import 'models.dart';
import 'models/ontology_models.dart';
import 'constants.dart';
import 'memorization/models.dart';
import 'services/memorization_service.dart';

// WHY: This directive points to the file that code-gen will create.
part 'providers.g.dart';

// --- Shared Preferences Provider ---
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

// (UI signals moved to utils/ui_signals.dart to avoid codegen dependencies.)

// --- App Data Service Provider (Unified Storage) ---
// WHY: Provides unified database for all user data (bookmarks, reading progress, memorization)
@Riverpod(keepAlive: true)
AppDataService appDataService(Ref ref) {
  return AppDataService();
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
    if (kDebugMode) {
      debugPrint(
        'CurrentPage: setPage called with $newPage (current state: $state)',
      );
    }
    // Always update state, even if it's the same value
    // This ensures listeners are notified even when navigating to the current page
    // (e.g., when returning from audio config screen)
    if (state != newPage) {
      state = newPage;
    } else {
      // Force a rebuild by setting to the same value
      // This is needed for cases where we're already on the target page
      // but need to ensure navigation happens (e.g., coming back from audio config)
      state = newPage;
    }
  }
}

// --- Database Service Provider ---
// WHY: This is a keepAlive provider for managing database operations with layout switching.
@Riverpod(keepAlive: true)
class DatabaseServiceNotifier extends _$DatabaseServiceNotifier {
  DatabaseService? _service;

  @override
  Future<DatabaseService> build() async {
    // WHY: Close previous service if exists (layout change scenario)
    // Store reference to prevent double-close if provider rebuilds quickly
    final previousService = _service;
    if (previousService != null) {
      await previousService.close();
    }

    final layout = ref.watch(mushafLayoutSettingProvider);
    _service = DatabaseService();
    await _service!.init(layout: layout);

    // WHY: Ensure cleanup on dispose. Clear reference first to prevent double-close.
    ref.onDispose(() async {
      final serviceToClose = _service;
      _service = null; // Clear reference first to prevent race conditions
      await serviceToClose?.close();
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

// --- Page Preview with Font Provider ---
// WHY: Combines pagePreview and pageFontFamily to avoid nested AsyncValue.when() calls
// in PageListView widget. This reduces unnecessary rebuilds and simplifies the widget tree.
@riverpod
Future<(String, String)> pagePreviewWithFont(Ref ref, int pageNumber) async {
  final preview = await ref.watch(pagePreviewProvider(pageNumber).future);
  final font = await ref.watch(pageFontFamilyProvider(pageNumber).future);
  return (preview, font);
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
  static const String _preferencesKey = 'mushaf_layout';

  @override
  MushafLayout build() {
    // WHY: Watch SharedPreferences to ensure it's loaded before reading
    // This prevents returning default value before saved preference is available
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    if (prefsAsync.hasValue) {
      final savedLayout = prefsAsync.value!.getString(_preferencesKey);
      if (savedLayout != null) {
        try {
          final layout = MushafLayout.values.firstWhere(
            (e) => e.name == savedLayout,
          );
          return layout;
        } catch (e) {
          // Invalid value, fall back to default
        }
      }
    }
    // Default to Uthmani if SharedPreferences not loaded or no saved value
    return MushafLayout.uthmani15Lines;
  }

  Future<void> setLayout(MushafLayout layout) async {
    // WHY: Update state synchronously first, then save asynchronously
    // This ensures the state is updated before any watchers react
    state = layout;
    // Save to SharedPreferences using provider
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_preferencesKey, layout.name);
    } catch (e) {
      // Handle potential errors, e.g., if storage is unavailable
      if (kDebugMode) {
        debugPrint('Failed to save mushaf layout: $e');
      }
    }
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
  @override
  List<String> build() {
    final prefs = ref.read(sharedPreferencesProvider).value;
    final historyJson =
        prefs?.getStringList(SearchHistoryConstants.preferencesKey) ?? [];
    return historyJson.take(SearchHistoryConstants.maxHistoryItems).toList();
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
    if (currentHistory.length > SearchHistoryConstants.maxHistoryItems) {
      currentHistory.removeRange(
        SearchHistoryConstants.maxHistoryItems,
        currentHistory.length,
      );
    }

    state = currentHistory;

    // Save to preferences
    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.setStringList(SearchHistoryConstants.preferencesKey, currentHistory);
  }

  void clearHistory() {
    state = [];
    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.remove(SearchHistoryConstants.preferencesKey);
  }

  void removeFromHistory(String query) {
    final currentHistory = List<String>.from(state);
    currentHistory.remove(query);
    state = currentHistory;

    final prefs = ref.read(sharedPreferencesProvider).value;
    prefs?.setStringList(SearchHistoryConstants.preferencesKey, currentHistory);
  }
}

// --- Bookmarks Service Provider ---
@Riverpod(keepAlive: true)
Future<BookmarksService> bookmarksService(Ref ref) async {
  // WHY: Use consistent async pattern - await both async dependencies
  // to avoid unnecessary rebuilds when mixing watch() and watch().future
  final appDataService = ref.watch(appDataServiceProvider);
  final dbService = await ref.watch(databaseServiceProvider.future);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final service = SqliteBookmarksService(appDataService, dbService);
  // WHY: Inject SharedPreferences from provider for dependency injection pattern
  service.setSharedPreferences(prefs);
  return service;
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
    // WHY: Explicitly request ayah text for UI display in BookmarksListView
    return service.getAllBookmarks(includeAyahText: true);
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

// --- Page Data with Bookmarks Provider ---
// WHY: Combines pageData and bookmarks to avoid nested AsyncValue.when() calls
@riverpod
Future<(PageData, List<Bookmark>)> pageDataWithBookmarks(
  Ref ref,
  int pageNumber,
) async {
  final pageData = await ref.watch(pageDataProvider(pageNumber).future);
  final bookmarks = await ref.watch(bookmarksProvider.future);
  return (pageData, bookmarks);
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
    // WHY: Log error for debugging and monitoring
    // Silent failures make it impossible to diagnose production issues
    if (kDebugMode) {
      debugPrint(
        'Failed to get page number for bookmark (surah: $surahNumber, ayah: $ayahNumber): $e',
      );
      // TODO: Include stackTrace and report to crash analytics when implemented
      // catch (e, stackTrace) { ... FirebaseCrashlytics.instance.recordError(e, stackTrace); }
    }
    return null;
  }
}

// --- Reading Progress Service Provider ---
@Riverpod(keepAlive: true)
Future<ReadingProgressService> readingProgressService(Ref ref) async {
  final appDataService = ref.watch(appDataServiceProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final service = SqliteReadingProgressService(appDataService);
  // WHY: Inject SharedPreferences from provider for dependency injection pattern
  service.setSharedPreferences(prefs);
  return service;
}

// --- Reading Statistics Provider ---
@riverpod
Future<ReadingStatistics> readingStatistics(Ref ref) async {
  final service = await ref.watch(readingProgressServiceProvider.future);
  return service.getStatistics();
}

// --- Pages Read Today Provider ---
@riverpod
Future<int> pagesReadToday(Ref ref) async {
  final service = await ref.watch(readingProgressServiceProvider.future);
  return service.getPagesReadToday();
}

// --- Current Streak Provider ---
@riverpod
Future<int> currentStreak(Ref ref) async {
  final service = await ref.watch(readingProgressServiceProvider.future);
  return service.getCurrentStreak();
}

// --- Theme Mode Enum ---
// WHY: Defined here for centralized provider management
enum AppThemeMode { light, dark, sepia, system }

// --- Primary Color Provider ---
// WHY: Manages custom primary color for personalization across themes
@Riverpod(keepAlive: true)
class PrimaryColorNotifier extends _$PrimaryColorNotifier {
  @override
  int build() {
    // WHY: Try to read initial value from SharedPreferences synchronously
    final prefsAsync = ref.read(sharedPreferencesProvider);
    if (prefsAsync.hasValue) {
      final savedColor = prefsAsync.value!.getInt(
        PrimaryColorConstants.preferencesKey,
      );
      if (savedColor != null) {
        return savedColor;
      }
    }
    // Default to teal if SharedPreferences not loaded or no saved value
    return PrimaryColorConstants.defaultColor;
  }

  Future<void> setPrimaryColor(int colorValue) async {
    state = colorValue;
    // Save to SharedPreferences using provider
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setInt(PrimaryColorConstants.preferencesKey, colorValue);
    } catch (e) {
      // Handle potential errors, e.g., if storage is unavailable
      if (kDebugMode) {
        debugPrint('Failed to save primary color: $e');
      }
    }
  }
}

// --- Theme Provider ---
// WHY: Migrated from legacy StateNotifier to codegen @riverpod pattern
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  AppThemeMode build() {
    // WHY: Try to read initial value from SharedPreferences synchronously
    // Similar pattern to SearchHistory provider (line 253)
    final prefsAsync = ref.read(sharedPreferencesProvider);
    if (prefsAsync.hasValue) {
      final savedTheme = prefsAsync.value!.getString('theme_mode');
      if (savedTheme != null) {
        try {
          return AppThemeMode.values.firstWhere((e) => e.name == savedTheme);
        } catch (e) {
          // Invalid value, fall back to system
        }
      }
    }
    // Default to system if SharedPreferences not loaded or no saved value
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
      if (kDebugMode) {
        debugPrint('Failed to save theme mode: $e');
      }
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
  late final MemorizationStorage _storage = _createStorage(ref);
  MemorizationConfig _config = const MemorizationConfig();

  // WHY: Creates SQLite-based memorization storage for persistent sessions
  MemorizationStorage _createStorage(Ref ref) {
    final appDataService = ref.watch(appDataServiceProvider);
    return SqliteMemorizationStorage(appDataService);
  }

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

// --- Ontology Service Provider ---
@Riverpod(keepAlive: true)
class OntologyServiceNotifier extends _$OntologyServiceNotifier {
  OntologyService? _service;

  @override
  Future<OntologyService> build() async {
    final previousService = _service;
    if (previousService != null) {
      await previousService.close();
    }

    try {
      _service = OntologyService();
      await _service!.ensureInitialized();

      ref.onDispose(() async {
        final serviceToClose = _service;
        _service = null;
        await serviceToClose?.close();
      });

      return _service!;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OntologyServiceProvider build failed: $e\n$stackTrace');
      }
      rethrow;
    }
  }
}

// --- Topic by ID Provider ---
@riverpod
Future<Topic> topicById(Ref ref, int topicId) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getTopicById(topicId);
}

// --- Topics for Ayah Provider ---
@riverpod
Future<List<Topic>> topicsForAyah(
  Ref ref,
  int surahNumber,
  int ayahNumber,
) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getTopicsForAyah(surahNumber, ayahNumber);
}

// --- Verses for Topic Provider ---
@riverpod
Future<List<VerseReference>> versesForTopic(Ref ref, int topicId) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getVersesForTopic(topicId);
}

// --- Related Topics Provider ---
@riverpod
Future<List<Topic>> relatedTopics(Ref ref, int sourceTopicId) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getRelatedTopics(sourceTopicId);
}

// --- Root Topics Provider ---
@Riverpod(keepAlive: true)
Future<List<Topic>> rootTopics(Ref ref) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getRootTopics();
}

// --- Root Topics by Hierarchy Provider ---
// WHY: Keep alive to prevent repeated queries when widget rebuilds
@Riverpod(keepAlive: true)
Future<List<Topic>> rootTopicsByHierarchy(Ref ref, bool thematic) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getRootTopicsByHierarchy(thematic: thematic);
}

// --- Child Topics Provider ---
@riverpod
Future<List<Topic>> childTopics(Ref ref, int topicId, bool thematic) async {
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.getChildTopics(topicId, thematic: thematic);
}

// --- Search Topics Provider ---
@riverpod
Future<List<Topic>> searchTopics(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];
  final service = await ref.watch(ontologyServiceProvider.future);
  return service.searchTopics(query);
}

// --- Audio Service Provider ---
@Riverpod(keepAlive: true)
Future<AudioService> audioService(Ref ref) async {
  final dbService = await ref.watch(databaseServiceProvider.future);
  final service = AudioService(dbService);

  // Dispose audio service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

// --- Audio State Provider ---
@Riverpod(keepAlive: true)
class AudioStateNotifier extends _$AudioStateNotifier {
  StreamSubscription<dynamic>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isRepeating = false; // Flag to prevent concurrent repeat calls

  @override
  AudioState build() {
    // Set up listener for player state changes
    _setupPlayerStateListener();

    // Clean up subscriptions on dispose
    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _positionSubscription?.cancel();
    });

    return const AudioState(
      isPlaying: false,
      currentSurahNumber: null,
      currentAyahNumber: null,
      endAyahNumber: null,
      position: null,
      duration: null,
    );
  }

  void _setupPlayerStateListener() async {
    // Cancel existing subscription if any
    await _playerStateSubscription?.cancel();

    try {
      final audioService = await ref.read(audioServiceProvider.future);
      _playerStateSubscription = audioService.playerStateStream.listen((
        playerState,
      ) {
        // Update state whenever player state changes
        _updateState(audioService);
      });
    } catch (e) {
      // Ignore errors during setup
    }
  }

  void _setupRepeatModeListener(
    AudioService audioService,
    int surahNumber,
    int ayahNumber,
  ) async {
    // Cancel existing subscription if any
    await _positionSubscription?.cancel();

    // Listen to position stream to detect when ayah ends
    _positionSubscription = audioService.positionStream.listen((
      position,
    ) async {
      // Prevent concurrent repeat calls
      if (_isRepeating) return;

      final currentAyah = audioService.currentAyahSegment;
      if (currentAyah == null) return;

      final endTime = Duration(milliseconds: currentAyah.timestampTo);

      // If we've reached the end (check position >= endTime, regardless of playing state)
      if (position >= endTime) {
        // Handle range playback - just play once, no repetition
        // Check if we have an end ayah and if we've reached it
        if (state.endAyahNumber != null &&
            currentAyah.ayahNumber >= state.endAyahNumber!) {
          // Reached end of range - pause and stop
          if (kDebugMode) {
            debugPrint(
              'Range playback: Reached end ayah ${state.endAyahNumber}, pausing',
            );
          }
          try {
            await audioService.pause();
            _updateState(audioService);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error pausing at end of range: $e');
            }
          }
          return;
        }

        // Check if we should continue range playback
        if (state.endAyahNumber != null &&
            currentAyah.ayahNumber < state.endAyahNumber!) {
          // Continue to next ayah in range - use transition for smooth playback
          if (kDebugMode) {
            debugPrint(
              'Range playback: Continuing from ayah ${currentAyah.ayahNumber} to next (end: ${state.endAyahNumber})',
            );
          }
          _isRepeating = true;
          try {
            // Cancel the position subscription before moving to next
            await _positionSubscription?.cancel();
            // Move to next ayah in range
            await skipToNextAyah();
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error skipping to next ayah in range: $e');
            }
          } finally {
            _isRepeating = false;
          }
        } else {
          // No range or reached end - pause and stop when ayah finishes
          if (kDebugMode) {
            debugPrint(
              'Playback: Pausing at ayah ${currentAyah.ayahNumber} (end: ${state.endAyahNumber})',
            );
          }
          try {
            await audioService.pause();
            _updateState(audioService);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error pausing at end of ayah: $e');
            }
          }
        }
      }
    });
  }

  Future<void> playAyahRange(
    int surahNumber,
    int startAyah,
    int endAyah,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          'playAyahRange: Starting range playback from ayah $startAyah to $endAyah',
        );
      }
      // Start playing from start ayah with end ayah set
      state = state.copyWith(endAyahNumber: endAyah);
      if (kDebugMode) {
        debugPrint('playAyahRange: Set endAyahNumber to $endAyah in state');
      }
      await playAyah(surahNumber, startAyah);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing ayah range: $e');
      }
    }
  }

  Future<void> playAyah(
    int surahNumber,
    int ayahNumber, {
    bool isTransition = false,
  }) async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);

      // Play ayah - pass isTransition flag for smooth transitions
      await audioService.playAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        isTransition: isTransition,
      );

      // Set default playback speed (1.0)
      await audioService.setSpeed(1.0);

      // For transitions, update state immediately (player stays in playing state)
      // For normal play, wait a bit for player to start
      if (isTransition) {
        _updateState(audioService);
        // Set up position listener for the new ayah
        _setupRepeatModeListener(audioService, surahNumber, ayahNumber);
      } else {
        // Wait a brief moment for player to actually start
        await Future.delayed(const Duration(milliseconds: 200));
        // Update state immediately after starting playback
        _updateState(audioService);

        // Ensure listener is set up to keep state in sync
        _setupPlayerStateListener();

        // Set up position listener to handle repeat mode
        _setupRepeatModeListener(audioService, surahNumber, ayahNumber);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing ayah: $e');
      }
    }
  }

  Future<void> playSurah(int surahNumber) async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      await audioService.playSurah(surahNumber);
      // Set default playback speed (1.0)
      await audioService.setSpeed(1.0);
      // Update state immediately after starting playback
      _updateState(audioService);

      // Ensure listener is set up
      _setupPlayerStateListener();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing surah: $e');
      }
    }
  }

  Future<void> pause() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      await audioService.pause();
      _updateState(audioService);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error pausing audio: $e');
      }
    }
  }

  Future<void> resume() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      await audioService.resume();
      _updateState(audioService);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resuming audio: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      await audioService.stop();
      state = const AudioState(
        isPlaying: false,
        currentSurahNumber: null,
        currentAyahNumber: null,
        endAyahNumber: null,
        position: null,
        duration: null,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping audio: $e');
      }
    }
  }

  Future<void> skipToPreviousAyah() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      final currentSurah = audioService.currentSurahAudio?.surahNumber;
      final currentAyah = audioService.currentAyahSegment?.ayahNumber;

      if (currentSurah == null || currentAyah == null) return;

      // Get all segments for the current surah
      final segments = await ref
          .read(databaseServiceProvider.future)
          .then((db) => db.getSurahSegments(currentSurah));

      // Find current ayah index
      final currentIndex = segments.indexWhere(
        (s) => s.ayahNumber == currentAyah,
      );

      if (currentIndex < 0) return;

      // Go to previous ayah
      if (currentIndex > 0) {
        final previousAyah = segments[currentIndex - 1];
        await playAyah(previousAyah.surahNumber, previousAyah.ayahNumber);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error skipping to previous ayah: $e');
      }
    }
  }

  Future<void> skipToNextAyah() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);
      final currentSurah = audioService.currentSurahAudio?.surahNumber;
      final currentAyah = audioService.currentAyahSegment?.ayahNumber;

      if (currentSurah == null || currentAyah == null) return;

      // Get all segments for the current surah
      final segments = await ref
          .read(databaseServiceProvider.future)
          .then((db) => db.getSurahSegments(currentSurah));

      // Find current ayah index
      final currentIndex = segments.indexWhere(
        (s) => s.ayahNumber == currentAyah,
      );

      if (currentIndex < 0) return;

      // Go to next ayah - use isTransition=true to keep playing smoothly
      // Use transition for range playback
      final shouldTransition = state.endAyahNumber != null;

      if (currentIndex < segments.length - 1) {
        final nextAyah = segments[currentIndex + 1];
        await playAyah(
          nextAyah.surahNumber,
          nextAyah.ayahNumber,
          isTransition: shouldTransition,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error skipping to next ayah: $e');
      }
    }
  }

  void _updateState(AudioService audioService) {
    final currentSurah = audioService.currentSurahAudio;
    final currentAyah = audioService.currentAyahSegment;

    state = AudioState(
      isPlaying: audioService.isPlaying,
      currentSurahNumber: currentSurah?.surahNumber,
      currentAyahNumber: currentAyah?.ayahNumber,
      endAyahNumber:
          state.endAyahNumber, // Preserve end ayah for range playback
      position: audioService.position,
      duration: audioService.duration,
    );
  }
}
