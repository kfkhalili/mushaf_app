import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/utils/page_fit.dart';

void main() {
  // TextPainter measurement needs the bindings initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  LineInfo bodyLine(int lineNumber, String text) => LineInfo(
    lineNumber: lineNumber,
    lineType: 'ayah',
    isCentered: false,
    surahNumber: 1,
    words: [Word(text: text, surahNumber: 1, ayahNumber: lineNumber)],
  );

  const LineInfo ornamentLine = LineInfo(
    lineNumber: 1,
    lineType: 'surah_name',
    isCentered: true,
    surahNumber: 1,
  );

  group('PageFit.bodyFontSize (pure geometry)', () {
    test(
      'is bounded by the vertical ceiling when height is the constraint',
      () {
        // verticalUnits 30 => verticalCeiling = 600 / 30 = 20.
        // widest 500 @ probe 100 => horizontalCeiling = 100 * 400 / 500 = 80.
        final size = PageFit.bodyFontSize(
          verticalUnits: 30,
          widestLineWidthAtProbe: 500,
          box: const Size(400, 600),
        );
        expect(size, closeTo(20.0, 1e-9));
      },
    );

    test(
      'is bounded by the horizontal ceiling when width is the constraint',
      () {
        // verticalUnits 10 => verticalCeiling = 2000 / 10 = 200.
        // widest 1000 @ probe 100 => horizontalCeiling = 100 * 200 / 1000 = 20.
        final size = PageFit.bodyFontSize(
          verticalUnits: 10,
          widestLineWidthAtProbe: 1000,
          box: const Size(200, 2000),
        );
        expect(size, closeTo(20.0, 1e-9));
      },
    );

    test('falls back to the vertical ceiling when there are no body lines', () {
      final size = PageFit.bodyFontSize(
        verticalUnits: 20,
        widestLineWidthAtProbe: 0,
        box: const Size(400, 600),
      );
      expect(size, closeTo(30.0, 1e-9)); // 600 / 20
    });

    test('result is independent of the probe size (width scales linearly)', () {
      final atProbe100 = PageFit.bodyFontSize(
        verticalUnits: 24,
        widestLineWidthAtProbe: 800,
        box: const Size(300, 5000),
        probe: 100,
      );
      final atProbe50 = PageFit.bodyFontSize(
        verticalUnits: 24,
        widestLineWidthAtProbe: 400, // half the width at half the probe
        box: const Size(300, 5000),
        probe: 50,
      );
      expect(atProbe50, closeTo(atProbe100, 1e-9));
    });

    test('more vertical units on the same box yields a smaller size', () {
      // Ornament-heavy pages have more units than pure-body pages of the same
      // line count, so their body shrinks to fit (the page-604 overflow fix).
      const box = Size(400, 900);
      final pureBody = PageFit.bodyFontSize(
        verticalUnits: 31.5, // 15 body rows * 2.1
        widestLineWidthAtProbe: 0,
        box: box,
      );
      final withOrnaments = PageFit.bodyFontSize(
        verticalUnits: 32.175, // 9 body + 3 header + 3 basmallah rows
        widestLineWidthAtProbe: 0,
        box: box,
      );
      expect(withOrnaments, lessThan(pureBody));
    });

    test('verticalSafetyPx shaves the available height before dividing', () {
      // Without the guard: 600 / 20 = 30. With a 2px guard: 598 / 20 = 29.9.
      final withoutGuard = PageFit.bodyFontSize(
        verticalUnits: 20,
        widestLineWidthAtProbe: 0,
        box: const Size(400, 600),
      );
      final withGuard = PageFit.bodyFontSize(
        verticalUnits: 20,
        widestLineWidthAtProbe: 0,
        box: const Size(400, 600),
        verticalSafetyPx: 2.0,
      );
      expect(withoutGuard, closeTo(30.0, 1e-9));
      expect(withGuard, closeTo(29.9, 1e-9));
      expect(withGuard, lessThan(withoutGuard));
    });

    test('asserts on non-positive vertical units', () {
      expect(
        () => PageFit.bodyFontSize(
          verticalUnits: 0,
          widestLineWidthAtProbe: 100,
          box: const Size(400, 600),
        ),
        throwsAssertionError,
      );
    });
  });

  group('PageFit.measureWidestLineWidth', () {
    test('ignores ornament-only rows and returns 0 when no body lines', () {
      final width = PageFit.measureWidestLineWidth(const [
        ornamentLine,
      ], fontFamily: 'Roboto');
      expect(width, 0.0);
    });

    test('returns the widest body line, scaling with text length', () {
      final width = PageFit.measureWidestLineWidth([
        bodyLine(1, 'كلمة'),
        bodyLine(2, 'كلمة كلمة كلمة كلمة'),
      ], fontFamily: 'Roboto');
      final widthSingle = PageFit.measureWidestLineWidth([
        bodyLine(1, 'كلمة'),
      ], fontFamily: 'Roboto');
      expect(width, greaterThan(0));
      expect(width, greaterThan(widthSingle));
    });
  });

  group('PageFit.forPage', () {
    double bodyUnits(LineInfo line) => line.words.isEmpty ? 0.0 : 2.0;

    test('returns a positive size no larger than the vertical ceiling', () {
      const box = Size(400, 900);
      final page = PageLayout(
        pageNumber: 3,
        lines: [for (int i = 1; i <= 15; i++) bodyLine(i, 'كلمة كلمة كلمة')],
      );
      final size = PageFit.forPage(
        page,
        box: box,
        fontFamily: 'Roboto',
        rowUnits: bodyUnits,
      );
      final verticalCeiling = box.height / (page.lines.length * 2.0);
      expect(size, greaterThan(0));
      expect(size, lessThanOrEqualTo(verticalCeiling + 1e-9));
    });

    test('a page with taller ornament rows fits smaller than pure body', () {
      const box = Size(400, 900);
      double units(LineInfo line) => switch (line.lineType) {
        'surah_name' => 3.0,
        'basmallah' => 1.425,
        _ => 2.0,
      };
      final pureBody = PageLayout(
        pageNumber: 3,
        lines: [for (int i = 1; i <= 15; i++) bodyLine(i, 'كلمة')],
      );
      final ornamentHeavy = PageLayout(
        pageNumber: 604,
        lines: [
          for (int i = 1; i <= 3; i++) ...[
            const LineInfo(
              lineNumber: 0,
              lineType: 'surah_name',
              isCentered: true,
              surahNumber: 112,
            ),
            const LineInfo(
              lineNumber: 0,
              lineType: 'basmallah',
              isCentered: true,
              surahNumber: 0,
            ),
            bodyLine(i, 'كلمة'),
            bodyLine(i + 100, 'كلمة'),
            bodyLine(i + 200, 'كلمة'),
          ],
        ],
      );
      final pureSize = PageFit.forPage(
        pureBody,
        box: box,
        fontFamily: 'Roboto',
        rowUnits: units,
      );
      final ornamentSize = PageFit.forPage(
        ornamentHeavy,
        box: box,
        fontFamily: 'Roboto',
        rowUnits: units,
      );
      expect(ornamentSize, lessThan(pureSize));
    });

    test('treats an empty page without dividing by zero', () {
      final size = PageFit.forPage(
        const PageLayout(pageNumber: 1, lines: []),
        box: const Size(400, 600),
        fontFamily: 'Roboto',
        rowUnits: bodyUnits,
      );
      expect(size, greaterThan(0));
    });
  });
}
