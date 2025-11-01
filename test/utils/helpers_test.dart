import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/utils/helpers.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('convertToEasternArabicNumerals', () {
    test('converts single digits correctly', () {
      expect(convertToEasternArabicNumerals('0'), '٠');
      expect(convertToEasternArabicNumerals('1'), '١');
      expect(convertToEasternArabicNumerals('5'), '٥');
      expect(convertToEasternArabicNumerals('9'), '٩');
    });

    test('converts multi-digit numbers', () {
      expect(convertToEasternArabicNumerals('123'), '١٢٣');
      expect(convertToEasternArabicNumerals('604'), '٦٠٤');
    });

    test('preserves non-numeric characters', () {
      expect(convertToEasternArabicNumerals('Page 1'), 'Page ١');
      expect(convertToEasternArabicNumerals('123 abc 456'), '١٢٣ abc ٤٥٦');
    });

    test('handles empty string', () {
      expect(convertToEasternArabicNumerals(''), '');
    });

    test('handles string with no digits', () {
      expect(convertToEasternArabicNumerals('abc'), 'abc');
    });
  });

  group('generateAyahKey', () {
    test('generates correct key with padding', () {
      expect(generateAyahKey(1, 1), '001:001');
      expect(generateAyahKey(1, 255), '001:255');
      expect(generateAyahKey(112, 1), '112:001');
      expect(generateAyahKey(114, 6), '114:006');
    });

    test('handles edge cases', () {
      expect(generateAyahKey(0, 0), '000:000');
      expect(generateAyahKey(999, 999), '999:999');
    });
  });

  group('extractQuranWordsFromPage', () {
    test('extracts words from ayah lines only', () {
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
            ],
          ),
          LineInfo(
            lineNumber: 2,
            lineType: 'bismillah',
            isCentered: true,
            surahNumber: 1,
            words: [const Word(text: 'بسم', surahNumber: 1, ayahNumber: 0)],
          ),
          LineInfo(
            lineNumber: 3,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [const Word(text: 'الحمد', surahNumber: 1, ayahNumber: 2)],
          ),
        ],
      );

      final words = extractQuranWordsFromPage(layout);
      expect(words.length, 3);
      expect(words[0].text, 'بسم');
      expect(words[1].text, 'الله');
      expect(words[2].text, 'الحمد');
      expect(words.every((w) => w.ayahNumber > 0), true);
    });

    test('filters out words with ayahNumber 0', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'ayah',
            isCentered: false,
            surahNumber: 1,
            words: [
              const Word(text: 'word1', surahNumber: 1, ayahNumber: 0),
              const Word(text: 'word2', surahNumber: 1, ayahNumber: 1),
            ],
          ),
        ],
      );

      final words = extractQuranWordsFromPage(layout);
      expect(words.length, 1);
      expect(words[0].text, 'word2');
    });

    test('returns empty list for no ayah lines', () {
      final layout = PageLayout(
        pageNumber: 1,
        lines: [
          LineInfo(
            lineNumber: 1,
            lineType: 'bismillah',
            isCentered: true,
            surahNumber: 1,
            words: [],
          ),
        ],
      );

      final words = extractQuranWordsFromPage(layout);
      expect(words, isEmpty);
    });
  });

  group('groupWordsByAyahKey', () {
    test('groups words by ayah key correctly', () {
      final words = [
        const Word(text: 'word1', surahNumber: 1, ayahNumber: 1),
        const Word(text: 'word2', surahNumber: 1, ayahNumber: 1),
        const Word(text: 'word3', surahNumber: 1, ayahNumber: 2),
        const Word(text: 'word4', surahNumber: 2, ayahNumber: 1),
      ];

      final grouped = groupWordsByAyahKey(words);
      expect(grouped.length, 3);
      expect(grouped['001:001']?.length, 2);
      expect(grouped['001:002']?.length, 1);
      expect(grouped['002:001']?.length, 1);
    });

    test('handles empty list', () {
      final grouped = groupWordsByAyahKey([]);
      expect(grouped, isEmpty);
    });
  });

  group('formatRelativeDate', () {
    test('returns today for current date', () {
      final now = DateTime.now();
      expect(formatRelativeDate(now), 'اليوم');
    });

    test('returns yesterday for 1 day ago', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(formatRelativeDate(yesterday), 'أمس');
    });

    test('returns days ago for 2-7 days', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final result = formatRelativeDate(threeDaysAgo);
      expect(result, contains('أيام'));
      expect(result, contains('٣'));
    });

    test('returns formatted date for more than 7 days', () {
      final oldDate = DateTime(2024, 1, 15);
      final result = formatRelativeDate(oldDate);
      expect(result, contains('يناير'));
      expect(result, isNot(contains('أيام')));
    });
  });

  group('formatPagesToday', () {
    test('returns correct text for 0', () {
      expect(formatPagesToday(0), 'لا صفحات اليوم');
    });

    test('returns correct text for 1', () {
      expect(formatPagesToday(1), 'صفحة واحدة اليوم');
    });

    test('returns correct text for 2', () {
      expect(formatPagesToday(2), 'صفحتان اليوم');
    });

    test('returns correct text for 3-10', () {
      expect(formatPagesToday(5), contains('صفحات اليوم'));
      expect(formatPagesToday(5), contains('٥'));
    });

    test('returns correct text for 11+', () {
      expect(formatPagesToday(15), contains('صفحة اليوم'));
      expect(formatPagesToday(15), contains('١٥'));
    });
  });

  group('formatPages', () {
    test('returns correct text for 0', () {
      expect(formatPages(0), 'لا صفحات');
    });

    test('returns correct text for 1', () {
      expect(formatPages(1), 'صفحة واحدة');
    });

    test('returns correct text for 2', () {
      expect(formatPages(2), 'صفحتان');
    });

    test('returns correct text for 3-10', () {
      expect(formatPages(5), contains('صفحات'));
      expect(formatPages(5), contains('٥'));
    });

    test('returns correct text for 11+', () {
      expect(formatPages(15), contains('صفحة'));
      expect(formatPages(15), contains('١٥'));
    });
  });

  group('formatDays', () {
    test('returns correct text for 1', () {
      expect(formatDays(1), 'يوم واحد');
    });

    test('returns correct text for 2', () {
      expect(formatDays(2), 'يومان');
    });

    test('returns correct text for 3-10', () {
      expect(formatDays(5), contains('أيام'));
      expect(formatDays(5), contains('٥'));
    });

    test('returns correct text for 11+', () {
      expect(formatDays(15), contains('يوما'));
      expect(formatDays(15), contains('١٥'));
    });
  });

  group('formatPagesProgress', () {
    test('formats progress correctly', () {
      final result = formatPagesProgress(50, 604);
      expect(result, contains('٥٠'));
      expect(result, contains('٦٠٤'));
      expect(result, contains('صفحة'));
    });

    test('handles zero progress', () {
      final result = formatPagesProgress(0, 604);
      expect(result, contains('لا صفحات'));
      expect(result, contains('٦٠٤'));
    });

    test('handles full progress', () {
      final result = formatPagesProgress(604, 604);
      expect(result, contains('٦٠٤'));
    });
  });

  group('formatPagesPerDay', () {
    test('returns correct text for 0', () {
      expect(formatPagesPerDay(0), 'لا صفحات/يوم');
    });

    test('returns correct text for 1', () {
      expect(formatPagesPerDay(1), 'صفحة واحدة/يوم');
    });

    test('returns correct text for 2', () {
      expect(formatPagesPerDay(2), 'صفحتان/يوم');
    });

    test('returns correct text for 3-10', () {
      expect(formatPagesPerDay(5), contains('صفحات/يوم'));
      expect(formatPagesPerDay(5), contains('٥'));
    });

    test('returns correct text for 11+', () {
      expect(formatPagesPerDay(15), contains('صفحة/يوم'));
      expect(formatPagesPerDay(15), contains('١٥'));
    });
  });

  group('formatDaysOutOf', () {
    test('formats correctly', () {
      final result = formatDaysOutOf(5, 7);
      expect(result, contains('أيام'));
      expect(result, contains('٥'));
      expect(result, contains('٧'));
      expect(result, contains('من'));
    });

    test('handles edge cases', () {
      expect(formatDaysOutOf(1, 7), contains('يوم واحد'));
      expect(formatDaysOutOf(2, 7), contains('يومان'));
    });
  });
}
