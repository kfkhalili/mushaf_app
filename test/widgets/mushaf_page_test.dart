import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/mushaf_page.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

import '../support/harness.dart';

void main() {
  group('MushafPage', () {
    testWidgets('renders loading state initially', (tester) async {
      await pumpScreen(tester, Scaffold(body: const MushafPage(pageNumber: 1)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state when page data fails', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(body: const MushafPage(pageNumber: 1)),
        overrides: [
          pageDataProvider.overrideWith(
            (ref, pageNumber) => Future<PageData>.error('Error'),
          ),
        ],
      );

      // WHY pumpAndSettle (not settle): the error propagates through the
      // chained pageDataWithBookmarksProvider via several microtask turns, which
      // only zero-duration settling drains — fixed-step pumps never surface it.
      await tester.pumpAndSettle();
      expect(find.textContaining('Error'), findsWidgets);
    });

    testWidgets('renders page with data successfully', (tester) async {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1)],
          ),
        ],
      );

      final pageData = PageData(
        layout: layout,
        pageFontFamily: 'Uthmani',
        pageSurahName: 'الفاتحة',
        pageSurahNumber: 1,
        juzNumber: 1,
        hizbNumber: 1,
      );

      await pumpScreen(
        tester,
        Scaffold(body: const MushafPage(pageNumber: 1)),
        overrides: [
          pageDataProvider.overrideWith(
            (ref, pageNumber) => Future.value(pageData),
          ),
        ],
      );

      await settle(tester);

      expect(find.byType(MushafPage), findsOneWidget);
    });
  });
}
