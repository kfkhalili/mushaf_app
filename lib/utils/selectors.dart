import 'dart:collection';
import '../models.dart';
import '../memorization/models.dart';
import '../utils/helpers.dart';

String derivePreviewText(PageData pageData, {int wordCount = 3}) {
  final StringBuffer buffer = StringBuffer();
  int remaining = wordCount;
  for (final line in pageData.layout.lines) {
    if (line.lineType == 'ayah' && remaining > 0) {
      for (final word in line.words) {
        if (word.ayahNumber > 0) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(word.text);
          remaining -= 1;
          if (remaining == 0) break;
        }
      }
    }
    if (remaining == 0) break;
  }
  return buffer.isEmpty ? '…' : buffer.toString();
}

({Set<Word> visibleWords, Map<String, double> ayahOpacity})
computeMemorizationVisibility(
  PageLayout layout,
  MemorizationSessionState? session,
) {
  final Set<Word> visible = <Word>{};
  final Map<String, double> opacity = <String, double>{};
  if (session == null) {
    // Not memorizing: show all ayah words
    for (final line in layout.lines) {
      if (line.lineType == 'ayah') {
        for (final w in line.words) {
          if (w.ayahNumber > 0) visible.add(w);
        }
      }
    }
    return (visibleWords: visible, ayahOpacity: opacity);
  }

  final allQuranWordsOnPage = extractQuranWordsFromPage(layout);
  final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
    groupWordsByAyahKey(allQuranWordsOnPage),
  );
  final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();

  for (final idx in session.window.ayahIndices) {
    if (idx >= 0 && idx < orderedAyahKeys.length) {
      final String ayahKey = orderedAyahKeys[idx];
      visible.addAll(ayahsOnPageMap[ayahKey] ?? const <Word>[]);
    }
  }
  for (
    int i = 0;
    i < session.window.ayahIndices.length &&
        i < session.window.opacities.length;
    i++
  ) {
    final int idx = session.window.ayahIndices[i];
    if (idx >= 0 && idx < orderedAyahKeys.length) {
      final String key = orderedAyahKeys[idx];
      final double value = session.window.opacities[i];
      opacity[key] = value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value);
    }
  }

  return (visibleWords: visible, ayahOpacity: opacity);
}

/// Computes the memorization "center label" shown in the countdown circle: the
/// reader's current ayah position within its surah on [layout], as eastern
/// Arabic numerals — either "m" (when at the surah's first shown ayah) or
/// "m–n".
///
/// Returns null when there is nothing to label: no active [session], or the
/// page has no Quran ayat. The caller is responsible for only passing a session
/// that belongs to the page currently being displayed.
String? computeMemorizationLabel(
  PageLayout layout,
  MemorizationSessionState? session,
) {
  if (session == null) return null;

  final allQuranWordsOnPage = extractQuranWordsFromPage(layout);
  final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
    groupWordsByAyahKey(allQuranWordsOnPage),
  );
  final List<String> orderedKeys = ayahsOnPageMap.keys.toList();
  if (orderedKeys.isEmpty) return null;

  final int idx = session.lastAyahIndexShown.clamp(0, orderedKeys.length - 1);
  final List<String> parts = orderedKeys[idx].split(':'); // format: sss:aaa
  final int currentSurah = int.tryParse(parts[0]) ?? 0;
  final int currentAyahNum = int.tryParse(parts[1]) ?? 1;

  // First ayah index on this page that belongs to the current surah.
  int firstIndexOfCurrentSurah = 0;
  for (int i = 0; i < orderedKeys.length; i++) {
    final int s = int.tryParse(orderedKeys[i].split(':')[0]) ?? -1;
    if (s == currentSurah) {
      firstIndexOfCurrentSurah = i;
      break;
    }
  }
  final int startAyahNumForCurrentSurah =
      int.tryParse(orderedKeys[firstIndexOfCurrentSurah].split(':')[1]) ?? 1;

  final String m = convertToEasternArabicNumerals(
    startAyahNumForCurrentSurah.toString(),
  );
  final String n = convertToEasternArabicNumerals(currentAyahNum.toString());
  return currentAyahNum <= startAyahNumForCurrentSurah ? m : '$m–$n';
}
