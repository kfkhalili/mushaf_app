import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/utils/selectors.dart';
import 'package:mushaf_app/utils/helpers.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/memorization/models.dart';

typedef MemorizationWindow = AyahWindowState; // Alias for compatibility

void main() {
  group('derivePreviewText', () {
    test('returns first words from page layout', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [
              const Word(text: 'بسم', surahNumber: 1, ayahNumber: 1),
              const Word(text: 'الله', surahNumber: 1, ayahNumber: 1),
              const Word(text: 'الرحمن', surahNumber: 1, ayahNumber: 1),
            ],
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

      final preview = derivePreviewText(pageData, wordCount: 2);
      expect(preview, 'بسم الله');
    });

    test('skips words with ayahNumber 0', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [
              const Word(text: 'skip', surahNumber: 1, ayahNumber: 0),
              const Word(text: 'keep', surahNumber: 1, ayahNumber: 1),
            ],
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

      final preview = derivePreviewText(pageData, wordCount: 1);
      expect(preview, 'keep');
    });

    test('skips non-ayah lines', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'bismillah',
            isCentered: true,
            surahNumber: 1,
            words: [const Word(text: 'skip', surahNumber: 1, ayahNumber: 1)],
          ),
          LineInfo(
            lineNumber: 2,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [const Word(text: 'keep', surahNumber: 1, ayahNumber: 1)],
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

      final preview = derivePreviewText(pageData, wordCount: 1);
      expect(preview, 'keep');
    });

    test('returns ellipsis for empty result', () {
      final layout = PageLayout(pageNumber: 1, lines: []);
      final pageData = PageData(
        layout: layout,
        pageFontFamily: 'Uthmani',
        pageSurahName: '',
        pageSurahNumber: 0,
        juzNumber: 0,
        hizbNumber: 0,
      );

      final preview = derivePreviewText(pageData);
      expect(preview, '…');
    });
  });

  group('computeMemorizationVisibility', () {
    test('returns all words when session is null', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [
              const Word(text: 'word1', surahNumber: 1, ayahNumber: 1),
              const Word(text: 'word2', surahNumber: 1, ayahNumber: 2),
            ],
          ),
        ],
      );

      final result = computeMemorizationVisibility(layout, null);
      expect(result.visibleWords.length, 2);
      expect(result.ayahOpacity, isEmpty);
    });

    test('filters words based on session window', () {
      final word1 = const Word(text: 'word1', surahNumber: 1, ayahNumber: 1);
      final word2 = const Word(text: 'word2', surahNumber: 1, ayahNumber: 2);
      final word3 = const Word(text: 'word3', surahNumber: 1, ayahNumber: 3);

      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [word1, word2, word3],
          ),
        ],
      );

      final session = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0], // Only first ayah visible
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = computeMemorizationVisibility(layout, session);
      // Should only include words from first ayah
      expect(result.visibleWords, contains(word1));
      expect(result.visibleWords, isNot(contains(word2)));
      expect(result.visibleWords, isNot(contains(word3)));
    });

    test('clamps opacity values to 0.0-1.0 range', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [const Word(text: 'word1', surahNumber: 1, ayahNumber: 1)],
          ),
        ],
      );

      final session = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0],
          opacities: [1.5], // Above 1.0
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = computeMemorizationVisibility(layout, session);
      expect(result.ayahOpacity['001:001'], 1.0);
    });

    test('handles negative opacity', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [const Word(text: 'word1', surahNumber: 1, ayahNumber: 1)],
          ),
        ],
      );

      final session = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0],
          opacities: [-0.5], // Below 0.0
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = computeMemorizationVisibility(layout, session);
      expect(result.ayahOpacity['001:001'], 0.0);
    });
  });

  group('computeMemorizationLabel', () {
    // Builds a page where each ayah is one line with one word.
    PageLayout pageOf(List<({int surah, int ayah})> ayat) => PageLayout(
      pageNumber: 1,
      lines: [
        for (final a in ayat)
          LineInfo(
            lineNumber: a.ayah,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: a.surah,
            words: [Word(text: 't', surahNumber: a.surah, ayahNumber: a.ayah)],
          ),
      ],
    );

    MemorizationSessionState sessionAt(int lastShown, {int page = 1}) =>
        MemorizationSessionState(
          pageNumber: page,
          window: const AyahWindowState(
            ayahIndices: [],
            opacities: [],
            tapsSinceReveal: [],
          ),
          lastAyahIndexShown: lastShown,
          lastUpdatedAt: DateTime.now(),
          passCount: 0,
        );

    final one = convertToEasternArabicNumerals('1');
    final two = convertToEasternArabicNumerals('2');
    final three = convertToEasternArabicNumerals('3');
    final seven = convertToEasternArabicNumerals('7');
    const dash = '–'; // en dash, as used in the implementation

    test('shows a single number at a surah\'s first ayah on the page', () {
      final label = computeMemorizationLabel(
        pageOf([(surah: 2, ayah: 1), (surah: 2, ayah: 2), (surah: 2, ayah: 3)]),
        sessionAt(0),
      );
      expect(label, one);
    });

    test('shows a range once past the surah\'s first ayah', () {
      final label = computeMemorizationLabel(
        pageOf([(surah: 2, ayah: 1), (surah: 2, ayah: 2), (surah: 2, ayah: 3)]),
        sessionAt(2),
      );
      expect(label, '$one$dash$three');
    });

    test('resets the start number per surah on a cross-surah page', () {
      final page = pageOf([
        (surah: 1, ayah: 7),
        (surah: 2, ayah: 1),
        (surah: 2, ayah: 2),
      ]);
      // On the surah-1 ayah: m == n == 7 → single number.
      expect(computeMemorizationLabel(page, sessionAt(0)), seven);
      // Two ayat into surah 2: start resets to 1, not the page's first ayah.
      expect(computeMemorizationLabel(page, sessionAt(2)), '$one$dash$two');
    });

    test('clamps an out-of-range lastAyahIndexShown', () {
      final label = computeMemorizationLabel(
        pageOf([(surah: 2, ayah: 1), (surah: 2, ayah: 2)]),
        sessionAt(99),
      );
      expect(label, '$one$dash$two');
    });

    test('returns null for a null session', () {
      expect(
        computeMemorizationLabel(pageOf([(surah: 2, ayah: 1)]), null),
        isNull,
      );
    });

    test('returns null when the page has no ayat', () {
      expect(computeMemorizationLabel(pageOf([]), sessionAt(0)), isNull);
    });
  });
}
