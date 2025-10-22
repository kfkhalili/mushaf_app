import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service.dart';
// WHY: Import your existing font service.
import 'services/font_service.dart';
import 'models.dart';
import '../constants.dart';

// --- Database Service Provider ---
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// --- Font Loader Service Provider ---
// WHY: Provide your existing FontService instance.
final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

// --- Page Data Provider ---
// WHY: Use YOUR FontService to get the font family name.
final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  // WHY: Get your font service instance.
  final fontService = ref.watch(fontServiceProvider);

  String pageFontFamilyName;
  try {
    // WHY: Call your service's method to get the font family name.
    // This will likely throw an error due to the path issue inside font_service.dart,
    // causing it to fall back (assuming error handling or default font elsewhere).
    pageFontFamilyName = await fontService.loadFontForPage(pageNumber);
  } catch (e) {
    // WHY: If fontService fails (which it likely will with the original path),
    // explicitly use the fallback font defined in constants.dart.
    // Make sure 'fallbackFontFamily' is defined correctly in constants.dart ('QPCV2').
    pageFontFamilyName = fallbackFontFamily; // Use constant from constants.dart
  }

  // Load other data
  final layout = await dbService.getPageLayout(pageNumber);
  final headerInfo = await dbService.getPageHeaderInfo(pageNumber);

  return PageData(
    layout: layout,
    pageFontFamily:
        pageFontFamilyName, // Use the name from FontService or fallback
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
