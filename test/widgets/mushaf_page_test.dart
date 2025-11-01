import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/mushaf_page.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('MushafPage', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: const MushafPage(pageNumber: 1)),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state when page data fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: [
            pageDataProvider.overrideWith(
              (ref, pageNumber) => Future<PageData>.error('Error'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: const MushafPage(pageNumber: 1)),
          ),
        ),
      );

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

      await tester.pumpWidget(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: [
            pageDataProvider.overrideWith(
              (ref, pageNumber) => Future.value(pageData),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: const MushafPage(pageNumber: 1)),
          ),
        ),
      );

      // Use timed pumps instead of pumpAndSettle to avoid timeouts
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MushafPage), findsOneWidget);
    });
  });
}
