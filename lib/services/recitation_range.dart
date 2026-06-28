import 'database_service.dart';

/// A surah:ayah coordinate.
typedef AyahRef = ({int surah, int ayah});

/// Where a recitation range should end, relative to its start ayah.
enum RecitationEndOption { page, surah, juz }

/// Resolves the end of a recitation range from a start ayah and an
/// [RecitationEndOption].
///
/// WHY a module: deciding "recite to the end of this page / surah / juz" is
/// Quran-domain logic that previously lived inline in `AudioConfigScreen` with
/// no seam and no test. Behind this interface it is a function of
/// (start, option) that can be exercised without pumping a widget.
class RecitationRange {
  final DatabaseService _databaseService;

  const RecitationRange(this._databaseService);

  /// Returns the last ayah to recite when starting at [start] and ending at the
  /// boundary named by [option], or null when it cannot be resolved.
  ///
  /// [currentPage] is consulted only for [RecitationEndOption.page]; pass the
  /// page the reader is currently viewing.
  Future<AyahRef?> resolveEndAyah({
    required AyahRef start,
    required RecitationEndOption option,
    int? currentPage,
  }) async {
    switch (option) {
      case RecitationEndOption.page:
        if (currentPage == null) return null;
        return _toRef(await _databaseService.getLastAyahOnPage(currentPage));
      case RecitationEndOption.surah:
        final lastAyah = await _databaseService.getLastAyahInSurah(start.surah);
        if (lastAyah == null) return null;
        return (surah: start.surah, ayah: lastAyah);
      case RecitationEndOption.juz:
        final juz = await _databaseService.getJuzForAyah(
          start.surah,
          start.ayah,
        );
        if (juz == null) return null;
        return _toRef(await _databaseService.getLastAyahInJuz(juz));
    }
  }

  /// Converts a `{surah, ayah}` database row into an [AyahRef], or null when
  /// either field is missing.
  AyahRef? _toRef(Map<String, int>? raw) {
    if (raw == null) return null;
    final surah = raw['surah'];
    final ayah = raw['ayah'];
    if (surah == null || ayah == null) return null;
    return (surah: surah, ayah: ayah);
  }
}
