import 'dart:math'; // WHY: Import for min()
import 'package:flutter/material.dart';
import '../models.dart';
import '../constants.dart';

class LineWidget extends StatelessWidget {
  final LineInfo line;
  final String pageFontFamily;
  final bool isMemorizationMode;
  // WHY: We now pass visibility rules based on ayah keys.
  final Set<String> visibleAyahKeys;
  final String? hintAyahKey;
  final String? hintText;

  const LineWidget({
    super.key,
    required this.line,
    required this.pageFontFamily,
    this.isMemorizationMode = false,
    this.visibleAyahKeys = const {},
    this.hintAyahKey,
    this.hintText,
  });

  // WHY: Helper to build the text style for a word.
  TextStyle _getWordStyle({
    required double fontSize,
    required double lineHeight,
    required Color baseColor,
    required bool isVisible,
    required bool isHint, // This parameter is no longer used for color
  }) {
    Color wordColor = baseColor;
    if (isMemorizationMode) {
      // WHY: If the word is not visible (which includes hints, as they
      // are passed with isVisible: true), make it transparent.
      // Otherwise, it gets the default base color.
      if (!isVisible) {
        wordColor = Colors.transparent;
      }
    }

    return TextStyle(
      fontFamily: pageFontFamily,
      fontSize: fontSize,
      height: lineHeight,
      color: wordColor,
    );
  }

  // WHY: Helper to create the key for a word.
  String _getWordKey(Word word) {
    return "${word.surahNumber.toString().padLeft(3, '0')}:${word.ayahNumber.toString().padLeft(3, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // WHY: Default text color from the theme.
    final Color baseTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.black;

    String? fontFamily = fallbackFontFamily;
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    final double screenWidth = MediaQuery.of(context).size.width;
    // WHY: Get screen height for proportional scaling.
    final double screenHeight = MediaQuery.of(context).size.height;

    // WHY: We scale based on the *smallest* dimension to ensure everything
    // fits proportionally on both width and height (e.g., "contain").
    final double widthScale = screenWidth / referenceScreenWidth;
    final double heightScale = screenHeight / referenceScreenHeight;
    final double scaleFactor = min(widthScale, heightScale);

    double defaultDynamicFontSize = (baseFontSize * scaleFactor).clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );

    // WHY: This is the critical fix. The line height is a *multiplier*
    // of the font size. Since the font size is already scaled,
    // we just use the base multiplier, not a scaled one.
    final double dynamicLineHeight = baseLineHeight;

    // WHY: We define a tighter line height for non-ayah lines
    // like surah names and basmallah to reduce extra vertical space.
    const double tightLineHeight = 1.5;

    // --- Dynamic Padding Calculation ---
    // WHY: This calculates the available width for the line, factoring in
    // the page's own horizontal padding.
    final double availableWidth = screenWidth - (2 * pageHorizontalPadding);
    double dynamicLinePadding = 0.0;

    // WHY: If the available space is wider than our max content width,
    // we calculate the extra padding needed to center the content.
    if (availableWidth > maxLineContentWidth) {
      dynamicLinePadding = (availableWidth - maxLineContentWidth) / 2.0;
    }
    // --- End of Calculation ---

    Widget lineWidget;

    switch (line.lineType) {
      case 'surah_name':
        {
          final String surahNumPadded = line.surahNumber.toString().padLeft(
            3,
            '0',
          );
          final String surahNameText = 'surah$surahNumPadded surah-icon';
          const String headerText = 'header';

          final double surahNameFontSize =
              (defaultDynamicFontSize * surahNameScaleFactor).clamp(
                minSurahNameFontSize,
                maxSurahNameFontSize,
              );
          final double headerFontSize =
              (surahNameFontSize * surahHeaderScaleFactorRelativeToName).clamp(
                minSurahHeaderFontSize,
                maxSurahHeaderFontSize,
              );

          lineWidget = Stack(
            alignment: Alignment.center,
            children: [
              Text(
                surahNameText,
                style: TextStyle(
                  fontFamily: surahNameFontFamily,
                  fontSize: surahNameFontSize,
                  height: tightLineHeight, // WHY: Use tight line height
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: headerFontSize,
                  height: tightLineHeight, // WHY: Use tight line height
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
            ],
          );
          break;
        }

      case 'basmallah':
        {
          const String textToShow = basmallah;
          final double basmallahFontSize =
              (defaultDynamicFontSize * basmallahScaleFactor).clamp(
                minBasmallahFontSize,
                maxBasmallahFontSize,
              );
          lineAlignment = TextAlign.center;

          lineWidget = Text(
            textToShow,
            textDirection: TextDirection.rtl,
            textAlign: lineAlignment,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: basmallahFontSize,
              height: tightLineHeight, // WHY: Use tight line height
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break;
        }
      case 'ayah':
        {
          if (line.words.isEmpty) {
            lineWidget = const SizedBox.shrink();
            break;
          }

          // WHY: This is the core logic change.
          // We must check each word's visibility status.

          if (!line.isCentered) {
            final List<Widget> wordWidgets = line.words.map((word) {
              bool isVisible = true;
              bool isHint = false;

              if (isMemorizationMode && word.ayahNumber > 0) {
                final String key = _getWordKey(word);
                isVisible = visibleAyahKeys.contains(key);

                // WHY: Check if this *specific word* is the hint.
                // We check if it belongs to the hint ayah AND matches the
                // exact hint text (which we know is the first word).
                if (key == hintAyahKey && word.text == hintText) {
                  isHint = true;
                }
              }

              // WHY: We use an AnimatedSwitcher to fade the color of each word.
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  word.text,
                  // WHY: Use a key to make the switcher animate correctly.
                  key: ValueKey("${word.text}-$isVisible-$isHint"),
                  style: _getWordStyle(
                    fontSize: defaultDynamicFontSize,
                    lineHeight: dynamicLineHeight, // WHY: Use 2.4 height
                    baseColor: baseTextColor,
                    // WHY: The hint is visible, just styled differently.
                    isVisible: isVisible || isHint,
                    isHint: isHint,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              );
            }).toList();

            // WHY: We wrap the Row in our dynamic padding. This constrains
            // the `spaceBetween` to the `maxLineContentWidth`.
            lineWidget = Padding(
              padding: EdgeInsets.symmetric(horizontal: dynamicLinePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: wordWidgets,
              ),
            );
          } else {
            // WHY: Centered lines (e.g., end of surah) must use RichText.
            // AnimatedSwitcher doesn't work on TextSpans, so this will
            // snap instead of fade.
            final List<TextSpan> spans = line.words.map((word) {
              bool isVisible = true;
              bool isHint = false;

              if (isMemorizationMode && word.ayahNumber > 0) {
                final String key = _getWordKey(word);
                isVisible = visibleAyahKeys.contains(key);

                if (key == hintAyahKey && word.text == hintText) {
                  isHint = true;
                }
              }

              return TextSpan(
                text: "${word.text} ", // Add space
                style: _getWordStyle(
                  fontSize: defaultDynamicFontSize,
                  lineHeight: dynamicLineHeight, // WHY: Use 2.4 height
                  baseColor: baseTextColor,
                  isVisible: isVisible || isHint,
                  isHint: isHint,
                ),
              );
            }).toList();

            // WHY: Centered text doesn't need the padding, as
            // `textAlign: TextAlign.center` handles it correctly.
            lineWidget = Text.rich(
              TextSpan(children: spans),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            );
          }
          break;
        }
      default:
        {
          lineWidget = const SizedBox.shrink();
          break;
        }
    }

    // WHY: Non-ayah lines and non-memorization mode return the widget directly.
    if (line.lineType != 'ayah' || !isMemorizationMode) {
      return lineWidget;
    }

    // For 'ayah' lines, the animation is handled *inside* the widget
    // build logic (word by word), so we return it directly.
    return lineWidget;
  }
}
