import 'dart:collection'; // WHY: For SplayTreeMap to sort ayahs.
import 'dart:math'; // WHY: Import for min()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart';
import '../models.dart';
import '../screens/mushaf_screen.dart'; // WHY: Import to get memorizationProvider
import '../constants.dart';

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    // WHY: We watch the memorization state to know when to hide/show ayahs.
    final memorizationState = ref.watch(memorizationProvider);
    final isMemorizing = memorizationState.isMemorizationMode;
    // WHY: This is now the count of revealed *ayahs*.
    final int revealedAyahCount =
        memorizationState.revealedLinesMap[pageNumber] ?? 0;

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    // --- Responsive Scaling ---
    // WHY: We calculate the same scaleFactor here to make paddings
    // and header/footer fonts responsive, just like the line widget.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthScale = screenWidth / referenceScreenWidth;
    final double heightScale = screenHeight / referenceScreenHeight;
    final double scaleFactor = min(widthScale, heightScale);

    // WHY: Scale header/footer fonts that were previously absolute.
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

    // WHY: Scale padding values that were previously absolute.
    final double dynamicHeaderPadding = headerHorizontalPadding * scaleFactor;
    final double dynamicPageBottomPadding = pageBottomPadding * scaleFactor;
    final double dynamicFooterBottomPadding = footerBottomPadding * scaleFactor;
    final double dynamicFooterRightPadding = footerRightPadding * scaleFactor;
    final double dynamicFooterLeftPadding = footerLeftPadding * scaleFactor;
    // --- End Responsive Scaling ---

    return asyncPageData.when(
      data: (pageData) {
        final String juzGlyphString =
            'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
        final String surahNameGlyphString = (pageData.pageSurahNumber > 0)
            ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
            : '';

        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        // WHY: We need to find all unique ayahs on the page, in order.
        // A SplayTreeMap sorts them automatically by surah:ayah key.
        final ayahsOnPage = SplayTreeMap<String, List<Word>>();
        for (final line in pageData.layout.lines) {
          if (line.lineType == 'ayah') {
            for (final word in line.words) {
              if (word.ayahNumber > 0) {
                // Skip basmallahs (often marked as ayah 0)
                final String key =
                    "${word.surahNumber.toString().padLeft(3, '0')}:${word.ayahNumber.toString().padLeft(3, '0')}";
                ayahsOnPage.putIfAbsent(key, () => []).add(word);
              }
            }
          }
        }

        // WHY: This list now contains the unique ayah keys in order.
        final List<String> orderedAyahKeys = ayahsOnPage.keys.toList();

        String? hintText;
        String? hintAyahKey;

        // WHY: The hint is for the *next* ayah to be revealed.
        // This logic finds the Nth ayah (where N = revealedAyahCount).
        if (revealedAyahCount > 0 &&
            revealedAyahCount < orderedAyahKeys.length) {
          // The hint is for the ayah *at* the reveal count index.
          // e.g., count is 1, hint is for index 1 (the 2nd ayah).
          hintAyahKey = orderedAyahKeys[revealedAyahCount];
          final List<Word>? hintWords = ayahsOnPage[hintAyahKey];
          if (hintWords != null && hintWords.isNotEmpty) {
            hintText = hintWords.first.text;
          }
        }

        // WHY: This set contains all ayahs that should be fully visible.
        final Set<String> visibleAyahKeys = Set<String>.from(
          orderedAyahKeys.take(revealedAyahCount),
        );

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              // WHY: Use dynamic padding.
              padding: EdgeInsets.symmetric(horizontal: dynamicHeaderPadding),
              child: Center(
                child: Text(
                  juzGlyphString,
                  style: juzHizbStyle.copyWith(
                    fontFamily: quranCommonFontFamily,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                // WHY: Use dynamic padding.
                padding: EdgeInsets.symmetric(horizontal: dynamicHeaderPadding),
                child: Center(
                  child: Text(
                    surahNameGlyphString,
                    style: surahNameHeaderStyle.copyWith(
                      fontFamily: surahNameFontFamily,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  // WHY: Use dynamic padding.
                  bottom: dynamicPageBottomPadding,
                  // WHY: We use the base padding here, as line_widget
                  // calculates its own internal padding from this.
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
                      // WHY: Pass down the visibility rules
                      visibleAyahKeys: visibleAyahKeys,
                      hintAyahKey: hintAyahKey,
                      hintText: hintText,
                    );
                  }).toList(),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  // WHY: Use dynamic padding.
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
