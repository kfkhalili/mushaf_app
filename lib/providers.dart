import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';
import 'constants.dart'; // For fallbackFontFamily
import 'package:flutter/foundation.dart';

// --- Current Page Provider ---
// Manages the state of the currently viewed page number.
// WHY: This was added in the previous step to centralize page state.
final currentPageProvider = StateProvider<int>((ref) {
  // Default to 1. MushafScreen overrides this on init.
  return 1;
});

// --- Database Service Provider ---
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  // DatabaseService handles its own internal initialization via init()
  return DatabaseService();
});

// --- Font Loader Service Provider ---
final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

// --- Page Data Provider ---
// Provides PageData including the correct font family for a given page number.
final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  final fontService = ref.watch(fontServiceProvider);

  String pageFontFamilyName;
  try {
    // Attempt to load page-specific font via the service (uses incorrect path in original service)
    pageFontFamilyName = await fontService.loadFontForPage(pageNumber);
  } catch (e) {
    // Explicitly fall back to QPCV2 if the service fails
    pageFontFamilyName = fallbackFontFamily;
    // Log this fallback event in debug mode
    if (kDebugMode) {
      debugPrint("Using fallback font for page $pageNumber due to error: $e");
    }
  }

  // Load layout and header info asynchronously
  // WHY: We no longer need 'await dbService.init()' here,
  // as getPageLayout() and getPageHeaderInfo() will call it internally and safely.
  final layout = await dbService.getPageLayout(pageNumber);
  final headerInfo = await dbService.getPageHeaderInfo(pageNumber);

  return PageData(
    layout: layout,
    pageFontFamily: pageFontFamilyName, // Use name from FontService or fallback
    pageSurahName: headerInfo['surahName'] as String? ?? '',
    pageSurahNumber: headerInfo['surahNumber'] as int? ?? 0,
    juzNumber: headerInfo['juz'] as int? ?? 0,
    hizbNumber: headerInfo['hizb'] as int? ?? 0,
  );
});

// --- Surah List Provider ---
// Provides the list of SurahInfo for the SelectionScreen.
final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  // WHY: The explicit 'await dbService.init()' is removed.
  // 'getAllSurahs()' calls 'init()' internally, and our
  // DatabaseService refactor ensures this is safe and efficient.
  return dbService.getAllSurahs();
});

// --- Juz List Provider ---
// Provides the list of JuzInfo for the SelectionScree.
final juzListProvider = FutureProvider<List<JuzInfo>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  // WHY: This provider already (correctly) relied on the
  // internal 'init()' call in 'getAllJuzInfo()'.
  return dbService.getAllJuzInfo();
});

// --- Page Preview Provider ---
// Provides the first few words of a page for the SelectionScreen page list.
final pagePreviewProvider = FutureProvider.family<String, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  // WHY: This provider already (correctly) relied on the
  // internal 'init()' call in 'getFirstWordsOfPage()'.
  return dbService.getFirstWordsOfPage(pageNumber, count: 3);
});

// --- Page Font Family Provider ---
// Provides the correct font family name (dynamically loaded or fallback) for a page,
// specifically used by the PageListView in SelectionScreen for preview text.
final pageFontFamilyProvider = FutureProvider.family<String, int>((
  ref,
  pageNumber,
) async {
  final fontService = ref.watch(fontServiceProvider);
  try {
    // Attempt to load the page-specific font (likely fails with original service path)
    return await fontService.loadFontForPage(pageNumber);
  } catch (e) {
    // Return fallback on error
    if (kDebugMode) {
      debugPrint(
        "pageFontFamilyProvider: Using fallback font for page $pageNumber due to error: $e",
      );
    }
    return fallbackFontFamily; // Use constant from constants.dart
  }
});

// --- Theme Provider ---
// (Assuming this is defined elsewhere, e.g., theme_provider.dart)
// final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(...);
