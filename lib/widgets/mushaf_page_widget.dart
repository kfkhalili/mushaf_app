import 'dart:collection'; // For SplayTreeMap
import 'dart:math'; // For min()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart'; // Import constants
import '../models.dart';
import '../providers/memorization_provider.dart';

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: This line will now work because of the added import.
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    final session = ref.watch(memorizationSessionProvider);
    final bool isMemorizing =
        session != null && session.pageNumber == pageNumber;

    // Legacy memorization removed

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    // --- Responsive Scaling ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthScale = screenWidth / referenceScreenWidth;
    final double heightScale = screenHeight / referenceScreenHeight;
    final double scaleFactor = min(widthScale, heightScale);

    final footerTextStyle = TextStyle(
      fontSize: 16 * scaleFactor,
      color: textColor,
    );
    final double dynamicPageBottomPadding = pageBottomPadding * scaleFactor;
    final double dynamicFooterBottomPadding = footerBottomPadding * scaleFactor;
    final double dynamicFooterRightPadding = footerRightPadding * scaleFactor;
    final double dynamicFooterLeftPadding = footerLeftPadding * scaleFactor;
    // --- End Responsive Scaling ---

    return asyncPageData.when(
      data: (pageData) {
        final Set<Word> wordsToShow = {};
        final Map<String, double> ayahOpacity = {};

        // Only prepare words to show if memorizing (beta chaining window)
        if (isMemorizing) {
          // Use pure functions for functional data processing
          final allQuranWordsOnPage = extractQuranWordsFromPage(
            pageData.layout,
          );
          final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
            groupWordsByAyahKey(allQuranWordsOnPage),
          );
          final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();

          // Map absolute ayah indices -> ayah keys
          // Our session stores indices from 0..N-1
          final window = session.window;
          for (final idx in window.ayahIndices) {
            if (idx >= 0 && idx < orderedAyahKeys.length) {
              final String ayahKey = orderedAyahKeys[idx];
              wordsToShow.addAll(ayahsOnPageMap[ayahKey] ?? []);
            }
          }
          // Fill opacities aligned with window order
          for (
            int i = 0;
            i < window.ayahIndices.length && i < window.opacities.length;
            i++
          ) {
            final int idx = window.ayahIndices[i];
            if (idx >= 0 && idx < orderedAyahKeys.length) {
              final String key = orderedAyahKeys[idx];
              ayahOpacity[key] = window.opacities[i].clamp(0.0, 1.0);
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
                      ayahOpacities: ayahOpacity,
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
