import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart'; // For debugPrint
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';
import 'constants.dart'; // For fallbackFontFamily

// --- Database Service Provider ---
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// --- Font Loader Service Provider ---
final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

// --- Page Data Provider ---
final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  final fontService = ref.watch(fontServiceProvider);

  String pageFontFamilyName;
  try {
    pageFontFamilyName = await fontService.loadFontForPage(pageNumber);
  } catch (e) {
    pageFontFamilyName = fallbackFontFamily;
    debugPrint("Using fallback font for page $pageNumber due to error: $e");
  }

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
});

// --- Surah List Provider ---
final surahListProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  await dbService.init();
  return dbService.getAllSurahs();
});

// --- Juz List Provider ---
final juzListProvider = FutureProvider<List<JuzInfo>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getAllJuzInfo();
});

// --- Page Preview Provider ---
final pagePreviewProvider = FutureProvider.family<String, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getFirstWordsOfPage(pageNumber, count: 5);
});

// --- Page Font Family Provider ---
// WHY: Provides the correct font family name (dynamically loaded or fallback) for a page.
final pageFontFamilyProvider = FutureProvider.family<String, int>((
  ref,
  pageNumber,
) async {
  final fontService = ref.watch(fontServiceProvider);
  try {
    // Attempt to load the page-specific font
    return await fontService.loadFontForPage(pageNumber);
  } catch (e) {
    // Return fallback on error
    debugPrint(
      "pageFontFamilyProvider: Using fallback font for page $pageNumber due to error: $e",
    );
    return fallbackFontFamily; // Use constant from constants.dart
  }
});
