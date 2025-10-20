import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service.dart';
import 'services/font_service.dart';
import 'models.dart';

final fontServiceProvider = Provider<FontService>((ref) {
  return FontService();
});

// Use StateProvider if you need to replace the instance later,
// otherwise Provider is fine for singletons.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final pageDataProvider = FutureProvider.family<PageData, int>((
  ref,
  pageNumber,
) async {
  // Ensure the database service is initialized before fetching page data.
  // Riverpod automatically handles awaiting this initialization.
  final dbService = ref.watch(databaseServiceProvider);
  await dbService.init(); // Make sure DBs are ready

  // Fetch dependencies in parallel.
  final pageFontFamilyFuture = ref
      .watch(fontServiceProvider)
      .loadFontForPage(pageNumber);
  final layoutFuture = dbService.getPageLayout(pageNumber);
  final pageHeaderInfoFuture = dbService.getPageHeaderInfo(pageNumber);

  // Await results.
  final pageFontFamily = await pageFontFamilyFuture;
  final layout = await layoutFuture;
  final pageHeaderInfo = await pageHeaderInfoFuture;

  // Combine results into PageData.
  return PageData(
    layout: layout,
    pageFontFamily: pageFontFamily,
    pageSurahName:
        pageHeaderInfo['surahName'] as String? ?? '', // Handle potential null
    juzNumber: pageHeaderInfo['juz'] as int? ?? 0, // Handle potential null
    hizbNumber: pageHeaderInfo['hizb'] as int? ?? 0, // Handle potential null
  );
});
