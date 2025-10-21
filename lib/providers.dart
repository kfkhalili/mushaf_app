import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';

final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final pageAyahsProvider = FutureProvider.family<List<Ayah>, int>((
  ref,
  pageNumber,
) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getAyahsForPage(pageNumber);
});

final surahListProvider = FutureProvider<List<SurahInfo>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getAllSurahs();
});

final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  final dbService = ref.watch(databaseServiceProvider);
  await dbService.init();

  final pageFontFamilyFuture = ref
      .watch(fontServiceProvider)
      .loadFontForPage(pageNumber);
  final layoutFuture = dbService.getPageLayout(pageNumber);
  final pageHeaderInfoFuture = dbService.getPageHeaderInfo(pageNumber);

  final pageFontFamily = await pageFontFamilyFuture;
  final layout = await layoutFuture;
  final pageHeaderInfo = await pageHeaderInfoFuture;

  return PageData(
    layout: layout,
    pageFontFamily: pageFontFamily,
    pageSurahName: pageHeaderInfo['surahName'] as String? ?? '',
    pageSurahNumber: pageHeaderInfo['surahNumber'] as int? ?? 0,
    juzNumber: pageHeaderInfo['juz'] as int? ?? 0,
    // hizbNumber removed
  );
});
