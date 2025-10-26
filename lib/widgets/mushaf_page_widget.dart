import 'dart:collection'; // For SplayTreeMap
import 'dart:math'; // For min()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart'; // Import constants
import '../models.dart';
import '../screens/mushaf_screen.dart'; // For memorizationProvider

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  String _getAyahKey(int surah, int ayah) {
    return "${surah.toString().padLeft(3, '0')}:${ayah.toString().padLeft(3, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: This line will now work because of the added import.
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    final memorizationState = ref.watch(memorizationProvider);
    final isMemorizing = memorizationState.isMemorizationMode;
    // WHY: Corrected to read from 'lastRevealedAyahIndexMap'. -1 is the initial state.
    final int lastRevealedIndex =
        memorizationState.lastRevealedAyahIndexMap[pageNumber] ?? -1;

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    // --- Responsive Scaling ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthScale = screenWidth / referenceScreenWidth;
    final double heightScale = screenHeight / referenceScreenHeight;
    final double scaleFactor = min(widthScale, heightScale);

    final juzHizbStyle = TextStyle(
      fontSize: 24 * scaleFactor,
      color: textColor,
    );
    final surahNameHeaderStyle = TextStyle(
      fontSize: 28 * scaleFactor,
      color: textColor,
    );
    final footerTextStyle = TextStyle(
      fontSize: 16 * scaleFactor,
      color: textColor,
    );
    final double dynamicHeaderPadding = headerHorizontalPadding * scaleFactor;
    final double dynamicPageBottomPadding = pageBottomPadding * scaleFactor;
    final double dynamicFooterBottomPadding = footerBottomPadding * scaleFactor;
    final double dynamicFooterRightPadding = footerRightPadding * scaleFactor;
    final double dynamicFooterLeftPadding = footerLeftPadding * scaleFactor;
    // --- End Responsive Scaling ---

    return asyncPageData.when(
      data: (pageData) {
        final Set<Word> wordsToShow = {};

        // Only prepare words to show if memorizing and text is not hidden
        if (isMemorizing && !memorizationState.isTextHidden) {
          final ayahsOnPageMap = SplayTreeMap<String, List<Word>>();
          final List<Word> allQuranWordsOnPage = [];
          for (final line in pageData.layout.lines) {
            if (line.lineType == 'ayah') {
              for (final word in line.words) {
                if (word.ayahNumber > 0) {
                  allQuranWordsOnPage.add(word);
                  final String key = _getAyahKey(
                    word.surahNumber,
                    word.ayahNumber,
                  );
                  ayahsOnPageMap.putIfAbsent(key, () => []).add(word);
                }
              }
            }
          }
          final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();

          if (lastRevealedIndex == -1) {
            // ** Initial State: Show first N words **
            if (allQuranWordsOnPage.isNotEmpty) {
              wordsToShow.addAll(allQuranWordsOnPage.take(initialWordCount));
              // No hint
            }
          } else if (lastRevealedIndex >= 0) {
            // ** Subsequent States: Show completed Ayahs + Hint **
            int clampedLastRevealedIndex = lastRevealedIndex.clamp(
              -1,
              orderedAyahKeys.length - 1,
            );

            // --- Add words for fully revealed ayahs ---
            for (int i = 0; i <= clampedLastRevealedIndex; i++) {
              final String ayahKey = orderedAyahKeys[i];
              wordsToShow.addAll(ayahsOnPageMap[ayahKey] ?? []);
            }

            // --- Add the hint word ---
            // Hint is for the ayah *after* the last fully revealed one.
            int hintAyahIndex = clampedLastRevealedIndex + 1;
            if (hintAyahIndex < orderedAyahKeys.length) {
              final String hintAyahKey = orderedAyahKeys[hintAyahIndex];
              final List<Word>? hintWords = ayahsOnPageMap[hintAyahKey];
              if (hintWords != null && hintWords.isNotEmpty) {
                wordsToShow.add(hintWords.first);
              }
            }
          }
        } else if (!isMemorizing) {
          // If not in memorization mode, show all words
          for (final line in pageData.layout.lines) {
            if (line.lineType == 'ayah') {
              for (final word in line.words) {
                if (word.ayahNumber > 0) {
                  wordsToShow.add(word);
                }
              }
            }
          }
        }

        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: dynamicPageBottomPadding,
                  left: pageHorizontalPadding,
                  right: pageHorizontalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: pageData.layout.lines.map((line) {
                    return LineWidget(
                      line: line,
                      pageFontFamily: pageData.pageFontFamily,
                      isMemorizationMode: isMemorizing,
                      wordsToShow: wordsToShow,
                    );
                  }).toList(),
                ),
              ),
              Align(
                alignment: (pageNumber % 2 != 0)
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: dynamicFooterBottomPadding,
                    right: dynamicFooterRightPadding,
                    left: dynamicFooterLeftPadding,
                  ),
                  child: Text(pageNum, style: footerTextStyle),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(pageHorizontalPadding),
            child: Text(
              'Failed to load page $pageNumber.\n\nError: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
