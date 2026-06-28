import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/constants.dart';
import 'package:mushaf_app/services/juz_hizb_index.dart';

/// Builds a range row the way the bundled juz/hizb tables store them.
Map<String, dynamic> _row(
  int number,
  String numberCol,
  String first,
  String last,
) => {
  numberCol: number,
  DbConstants.firstVerseKeyCol: first,
  DbConstants.lastVerseKeyCol: last,
};

void main() {
  // A tiny stand-in for the real range tables — no database required.
  final juzRows = [
    _row(1, DbConstants.juzNumberCol, '1:1', '2:141'),
    _row(2, DbConstants.juzNumberCol, '2:142', '2:252'),
    _row(30, DbConstants.juzNumberCol, '78:1', '114:6'),
  ];
  final hizbRows = [
    _row(1, DbConstants.hizbNumberCol, '1:1', '2:74'),
    _row(2, DbConstants.hizbNumberCol, '2:75', '2:141'),
  ];

  final index = JuzHizbIndex(juzRows: juzRows, hizbRows: hizbRows);

  group('JuzHizbIndex.juzForAyah', () {
    test('returns the juz at a range boundary', () {
      expect(index.juzForAyah(1, 1), 1); // first ayah of juz 1
      expect(index.juzForAyah(2, 141), 1); // last ayah of juz 1
      expect(index.juzForAyah(2, 142), 2); // first ayah of juz 2
    });

    test('returns the juz for the last juz range', () {
      expect(index.juzForAyah(114, 6), 30);
    });

    test('returns 0 when no range contains the ayah', () {
      expect(index.juzForAyah(2, 300), 0); // beyond juz 2, before juz 30
    });
  });

  group('JuzHizbIndex.hizbForAyah', () {
    test('distinguishes adjacent hizb ranges', () {
      expect(index.hizbForAyah(2, 74), 1);
      expect(index.hizbForAyah(2, 75), 2);
    });

    test('returns 0 outside the known hizb ranges', () {
      expect(index.hizbForAyah(50, 1), 0);
    });
  });

  group('JuzHizbIndex.lastAyahInJuz', () {
    test('returns the end coordinate of a juz', () {
      expect(index.lastAyahInJuz(1), (surah: 2, ayah: 141));
      expect(index.lastAyahInJuz(30), (surah: 114, ayah: 6));
    });

    test('returns null for an unknown juz', () {
      expect(index.lastAyahInJuz(99), isNull);
    });
  });

  group('JuzHizbIndex.juzStarts', () {
    test('pairs each juz with its starting ayah, in order', () {
      final starts = index.juzStarts();
      expect(starts.length, 3);
      expect(starts.first, (juzNumber: 1, surah: 1, ayah: 1));
      expect(starts[1], (juzNumber: 2, surah: 2, ayah: 142));
      expect(starts.last, (juzNumber: 30, surah: 78, ayah: 1));
    });
  });

  group('JuzHizbIndex defensive parsing', () {
    test('skips rows with malformed or out-of-range keys', () {
      final bad = JuzHizbIndex(
        juzRows: [
          _row(1, DbConstants.juzNumberCol, 'not-a-key', '2:141'), // bad start
          _row(
            2,
            DbConstants.juzNumberCol,
            '2:142',
            '999:1',
          ), // bad end (surah)
          _row(3, DbConstants.juzNumberCol, '3:1', '3:200'),
        ],
        hizbRows: const [],
      );
      // juzStarts validates only the FIRST key (like getAllJuzInfo): row 1 is
      // dropped, row 2 keeps a usable start despite its unusable range.
      expect(bad.juzStarts(), [
        (juzNumber: 2, surah: 2, ayah: 142),
        (juzNumber: 3, surah: 3, ayah: 1),
      ]);
      // A containment lookup needs BOTH keys valid, so the malformed ranges of
      // rows 1 and 2 never match.
      expect(bad.juzForAyah(2, 142), 0);
      expect(bad.juzForAyah(3, 1), 3);
    });

    test('empty index resolves to 0 / null', () {
      const empty = JuzHizbIndex(juzRows: [], hizbRows: []);
      expect(empty.juzForAyah(1, 1), 0);
      expect(empty.hizbForAyah(1, 1), 0);
      expect(empty.lastAyahInJuz(1), isNull);
      expect(empty.juzStarts(), isEmpty);
    });
  });
}
