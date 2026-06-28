import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/memorization/models.dart';
import 'package:mushaf_app/models/ontology_models.dart';

void main() {
  // These tests pin the value-equality contract after moving the models to
  // Equatable. Several were genuine bugs before: the hand-rolled `==` compared
  // only a subset of fields, so objects that differ were treated as equal.

  group('Bookmark equality (previously omitted 4 fields)', () {
    final createdAt = DateTime(2024, 1, 1);
    Bookmark base() => Bookmark(
      id: 1,
      surahNumber: 2,
      ayahNumber: 255,
      cachedPageNumber: 42,
      createdAt: createdAt,
      note: null,
      ayahText: 'text',
    );

    test('identical bookmarks are equal and share a hashCode', () {
      expect(base(), equals(base()));
      expect(base().hashCode, base().hashCode);
    });

    test('differing only in note are NOT equal (was a bug)', () {
      expect(base().copyWith(note: 'changed'), isNot(equals(base())));
    });

    test('differing only in cachedPageNumber are NOT equal (was a bug)', () {
      expect(base().copyWith(cachedPageNumber: 99), isNot(equals(base())));
    });

    test('a Set deduplicates only truly-identical bookmarks', () {
      final set = {base(), base().copyWith(note: 'changed'), base()};
      expect(set.length, 2);
    });
  });

  group('ReadingSession equality (previously omitted timestamp)', () {
    final date = DateTime(2024, 5, 1);
    test('differing only in timestamp are NOT equal (was a bug)', () {
      final a = ReadingSession(
        id: 1,
        sessionDate: date,
        pageNumber: 10,
        timestamp: DateTime(2024, 5, 1, 9),
      );
      final b = a.copyWith(timestamp: DateTime(2024, 5, 1, 18));
      expect(b, isNot(equals(a)));
    });
  });

  group(
    'SearchResult equality (previously omitted context/word/surahName)',
    () {
      SearchResult base() => const SearchResult(
        text: 'الله',
        surahNumber: 1,
        ayahNumber: 1,
        pageNumber: 1,
        surahName: 'الفاتحة',
        context: 'a',
        wordPosition: 0,
      );
      test('differing only in context are NOT equal (was a bug)', () {
        const changed = SearchResult(
          text: 'الله',
          surahNumber: 1,
          ayahNumber: 1,
          pageNumber: 1,
          surahName: 'الفاتحة',
          context: 'b',
          wordPosition: 0,
        );
        expect(changed, isNot(equals(base())));
      });
    },
  );

  group('deep collection equality is preserved', () {
    PageLayout layout() => const PageLayout(
      pageNumber: 1,
      lines: [
        LineInfo(
          lineNumber: 1,
          lineType: 'ayah',
          isCentered: false,
          surahNumber: 1,
          words: [Word(text: 'a', surahNumber: 1, ayahNumber: 1)],
        ),
      ],
    );

    test('PageLayouts with value-equal (not identical) lines are equal', () {
      expect(layout(), equals(layout()));
      expect(layout().hashCode, layout().hashCode);
    });

    test('MemorizationSessionState compares its window list by value', () {
      MemorizationSessionState session(List<int> indices) =>
          MemorizationSessionState(
            pageNumber: 1,
            window: AyahWindowState(
              ayahIndices: indices,
              opacities: const [1.0],
              tapsSinceReveal: const [0],
            ),
            lastAyahIndexShown: 0,
            lastUpdatedAt: DateTime(2024, 1, 1),
            passCount: 0,
          );
      expect(session([0]), equals(session([0])));
      expect(session([0]), isNot(equals(session([1]))));
    });
  });

  group('Topic is an entity keyed by id', () {
    test('same topicId with different fields are still equal', () {
      const a = Topic(
        topicId: 5,
        arabicName: 'أ',
        isThematic: true,
        isOntology: false,
      );
      const b = Topic(
        topicId: 5,
        arabicName: 'ب',
        isThematic: false,
        isOntology: true,
      );
      expect(a, equals(b));
    });

    test('different topicId are not equal', () {
      const a = Topic(
        topicId: 5,
        arabicName: 'أ',
        isThematic: true,
        isOntology: false,
      );
      const b = Topic(
        topicId: 6,
        arabicName: 'أ',
        isThematic: true,
        isOntology: false,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
