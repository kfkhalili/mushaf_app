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

({Set<Word> visibleWords, Map<String, bool> ayahIsHidden}) computeMemorizationVisibility(
  PageLayout layout,
  MemorizationSessionState? session,
) {
  final Set<Word> visible = <Word>{};
  final Map<String, bool> isHidden = <String, bool>{};

  if (session == null) {
    // Not memorizing: show all ayah words
    for (final line in layout.lines) {
      if (line.lineType == 'ayah') {
        for (final w in line.words) {
          if (w.ayahNumber > 0) visible.add(w);
        }
      }
    }
    return (visibleWords: visible, ayahIsHidden: isHidden);
  }

  final allQuranWordsOnPage = extractQuranWordsFromPage(layout);
  final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
    groupWordsByAyahKey(allQuranWordsOnPage),
  );
  final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();

  // Show words from all ayat in the window
  // Previous and next ayat are always visible (for chaining context)
  // Current ayah visibility depends on isHidden state
  for (int i = 0; i < session.window.ayahIndices.length; i++) {
    final int idx = session.window.ayahIndices[i];
    if (idx >= 0 && idx < orderedAyahKeys.length) {
      final String ayahKey = orderedAyahKeys[idx];
      final bool hidden = i < session.window.isHidden.length
          ? session.window.isHidden[i]
          : true;

      // Track hidden state for this ayah
      isHidden[ayahKey] = hidden;

      // Only add to visible words if not hidden
      // OR if it's not the current ayah (show previous/next for context)
      final isCurrentAyah = idx == session.currentAyahIndex;
      if (!hidden || !isCurrentAyah) {
        visible.addAll(ayahsOnPageMap[ayahKey] ?? const <Word>[]);
      }
    }
  }

  return (visibleWords: visible, ayahIsHidden: isHidden);
}
