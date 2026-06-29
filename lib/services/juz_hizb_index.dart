import '../constants.dart';
import '../utils/parsing_helpers.dart';
import '../utils/validation_helpers.dart';
import 'database_store.dart';

/// In-memory index over the Juz' and Hizb range tables: given an ayah it answers
/// which Juz'/Hizb contains it, and where each Juz' begins and ends.
///
/// WHY a module: the containment logic previously lived as two ~50-line finders
/// (`_findJuz` / `_findHizb`) inside the 1600-line DatabaseService, differing
/// only in which range table they scanned and which number they returned. Here
/// it is a single `_findInRanges`, and the lookups are exercisable against
/// fixture rows without standing up a database.
class JuzHizbIndex {
  final List<Map<String, dynamic>> _juzRows;
  final List<Map<String, dynamic>> _hizbRows;

  /// Builds an index directly from range rows. Each row is a `{juz_number /
  /// hizb_number, first_verse_key, last_verse_key}` map. Use this in tests with
  /// fixture rows; production code uses [load].
  const JuzHizbIndex({
    required List<Map<String, dynamic>> juzRows,
    required List<Map<String, dynamic>> hizbRows,
  }) : _juzRows = juzRows,
       _hizbRows = hizbRows;

  /// Opens the bundled Juz' and Hizb databases via [store] just long enough to
  /// read their range tables, then returns the warmed index. The two
  /// connections are released before returning — they are never queried again.
  static Future<JuzHizbIndex> load(DatabaseStore store) async {
    final juzDb = await store.open(juzDbFileName);
    final hizbDb = await store.open(hizbDbFileName);
    try {
      final juzRows = await juzDb.query(
        DbConstants.juzTable,
        orderBy: '${DbConstants.juzNumberCol} ASC',
      );
      final hizbRows = await hizbDb.query(
        DbConstants.hizbsTable,
        orderBy: '${DbConstants.hizbNumberCol} ASC',
      );
      return JuzHizbIndex(juzRows: juzRows, hizbRows: hizbRows);
    } finally {
      await juzDb.close();
      await hizbDb.close();
    }
  }

  /// The Juz' number containing [surah]:[ayah], or 0 when none does.
  int juzForAyah(int surah, int ayah) =>
      _findInRanges(_juzRows, DbConstants.juzNumberCol, surah, ayah);

  /// The Hizb number containing [surah]:[ayah], or 0 when none does.
  int hizbForAyah(int surah, int ayah) =>
      _findInRanges(_hizbRows, DbConstants.hizbNumberCol, surah, ayah);

  /// The (surah, ayah) at which [juzNumber] ends, or null when unknown or
  /// malformed.
  ({int surah, int ayah})? lastAyahInJuz(int juzNumber) {
    for (final row in _juzRows) {
      if (parseInt(row[DbConstants.juzNumberCol]) != juzNumber) continue;
      return _parseVerseKey(row[DbConstants.lastVerseKeyCol] as String?);
    }
    return null;
  }

  /// Each Juz' paired with the (surah, ayah) it begins at, in Juz' order.
  /// Rows with a malformed or out-of-range first verse key are skipped.
  List<({int juzNumber, int surah, int ayah})> juzStarts() {
    final starts = <({int juzNumber, int surah, int ayah})>[];
    for (final row in _juzRows) {
      final start = _parseVerseKey(
        row[DbConstants.firstVerseKeyCol] as String?,
      );
      if (start == null) continue;
      starts.add((
        juzNumber: parseInt(row[DbConstants.juzNumberCol]),
        surah: start.surah,
        ayah: start.ayah,
      ));
    }
    return starts;
  }

  /// Scans [rows] for the range containing [surah]:[ayah] and returns that
  /// range's [numberCol] value, or 0 when no range contains the ayah.
  int _findInRanges(
    List<Map<String, dynamic>> rows,
    String numberCol,
    int surah,
    int ayah,
  ) {
    if (rows.isEmpty) return 0;
    for (final row in rows) {
      final first = _parseVerseKey(
        row[DbConstants.firstVerseKeyCol] as String?,
      );
      final last = _parseVerseKey(row[DbConstants.lastVerseKeyCol] as String?);
      if (first == null || last == null) continue; // Skip invalid ranges.
      if (_isAyahInRange(
        surah,
        ayah,
        first.surah,
        first.ayah,
        last.surah,
        last.ayah,
      )) {
        return parseInt(row[numberCol]);
      }
    }
    return 0;
  }

  /// Parses a `"surah:ayah"` verse key, validating both numbers.
  /// Returns null on malformed or out-of-range input.
  ///
  /// WHY: Defense in depth — validate even trusted database data.
  ({int surah, int ayah})? _parseVerseKey(String? key) {
    if (key == null || key.isEmpty) return null;
    final parts = key.split(':');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) return null;
    final surah = parseInt(parts[0]);
    final ayah = parseInt(parts[1]);
    try {
      validateSurahNumber(surah);
      validateAyahNumber(ayah);
    } catch (_) {
      return null;
    }
    return (surah: surah, ayah: ayah);
  }

  bool _isAyahInRange(
    int s,
    int a,
    int sFirst,
    int aFirst,
    int sLast,
    int aLast,
  ) {
    if (s < sFirst || s > sLast) return false; // Surah out of range.
    if (s == sFirst && a < aFirst) return false; // Before range start.
    if (s == sLast && a > aLast) return false; // After range end.
    return true;
  }
}
