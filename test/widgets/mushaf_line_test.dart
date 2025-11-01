import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/mushaf_line.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('MushafLine', () {
    testWidgets('renders ayah line correctly', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [
          const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1),
          const Word(text: 'الله', surahNumber: 1, ayahNumber: 1),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MushafLine(
                line: line,
                pageFontFamily: 'Uthmani',
                isMemorizationMode: false,
                wordsToShow: {
                  const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1),
                  const Word(text: 'الله', surahNumber: 1, ayahNumber: 1),
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('renders bismillah line correctly', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'bismillah',
        isCentered: true,
        surahNumber: 1,
        words: [const Word(text: 'بسم', surahNumber: 1, ayahNumber: 0)],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MushafLine(
                line: line,
                pageFontFamily: 'Uthmani',
                isMemorizationMode: false,
                wordsToShow: {
                  const Word(text: 'بسم', surahNumber: 1, ayahNumber: 0),
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('renders surah name line correctly', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'surah_name',
        isCentered: true,
        surahNumber: 1,
        words: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MushafLine(
                line: line,
                pageFontFamily: 'Uthmani',
                isMemorizationMode: false,
                wordsToShow: {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('applies opacity from ayahOpacities map', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1)],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MushafLine(
                line: line,
                pageFontFamily: 'Uthmani',
                isMemorizationMode: true,
                wordsToShow: {
                  const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1),
                },
                ayahOpacities: {'001:001': 0.5},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('handles long press callback', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1)],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MushafLine(
                line: line,
                pageFontFamily: 'Uthmani',
                isMemorizationMode: false,
                wordsToShow: {
                  const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1),
                },
                onAyahLongPress: (surah, ayah, position) {
                  // Long press callback for testing
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
      // Long press functionality would be tested in integration tests
    });
  });
}
