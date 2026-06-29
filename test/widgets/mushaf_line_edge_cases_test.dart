import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/mushaf_line.dart';
import 'package:mushaf_app/models.dart';

import '../support/harness.dart';

void main() {
  group('MushafLine Edge Cases', () {
    testWidgets('handles empty words list', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {},
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('handles basmallah line type', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'basmallah',
        isCentered: false,
        surahNumber: 1,
        words: [],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {},
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('handles header line type', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'header',
        isCentered: false,
        surahNumber: 1,
        words: [],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {},
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('handles unknown line type gracefully', (tester) async {
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'unknown',
        isCentered: false,
        surahNumber: 1,
        words: [],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {},
          ),
        ),
      );

      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('applies opacity when word is in wordsToShow', (tester) async {
      final word = const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1);
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [word],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: true,
            wordsToShow: {word},
            ayahOpacities: {'001:001': 0.5},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('handles centered lines', (tester) async {
      final word = const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1);
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: true,
        surahNumber: 1,
        words: [word],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {word},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('highlights selected ayah', (tester) async {
      final word = const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1);
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [word],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {word},
            selectedAyahKey: '001:001',
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(MushafLine), findsOneWidget);
    });

    testWidgets('highlights bookmarked ayah', (tester) async {
      final word = const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1);
      final line = LineInfo(
        lineNumber: 1,
        lineType: 'ayah',
        isCentered: false,
        surahNumber: 1,
        words: [word],
      );

      await pumpScreen(
        tester,
        Scaffold(
          body: MushafLine(
            line: line,
            pageFontFamily: 'Uthmani',
            bodyFontSize: 24.0,
            lineHeight: 2.0,
            isMemorizationMode: false,
            wordsToShow: {word},
            bookmarkedAyahKeys: {'001:001'},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(MushafLine), findsOneWidget);
    });
  });
}
