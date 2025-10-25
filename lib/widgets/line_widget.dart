import 'dart:math'; // For min()
import 'package:flutter/material.dart';
import '../models.dart';
import '../constants.dart';

class LineWidget extends StatelessWidget {
  final LineInfo line;
  final String pageFontFamily;
  final bool isMemorizationMode;
  // WHY: Accept the set of words that should be visible.
  final Set<Word> wordsToShow;

  const LineWidget({
    super.key,
    required this.line,
    required this.pageFontFamily,
    required this.isMemorizationMode,
    required this.wordsToShow, // Use this set to determine visibility
  });

  // WHY: Simplified style helper - only needs visibility flag.
  TextStyle _getWordStyle({
    required double fontSize,
    required double lineHeight,
    required Color baseColor,
    required bool isVisible,
  }) {
    // WHY: Use transparent color if not visible in memorization mode.
    Color wordColor = (isMemorizationMode && !isVisible)
        ? Colors.transparent
        : baseColor;

    return TextStyle(
      fontFamily: pageFontFamily,
      fontSize: fontSize,
      height: lineHeight,
      color: wordColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseTextColor =
        theme.textTheme.bodyLarge?.color ?? Colors.black;

    String? fontFamily = quranCommonFontFamily; // For Basmallah
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    // --- Responsive Scaling ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double widthScale = screenWidth / referenceScreenWidth;
    final double heightScale = screenHeight / referenceScreenHeight;
    final double scaleFactor = min(widthScale, heightScale);
    final double unclampedDynamicFontSize = baseFontSize * scaleFactor;
    double defaultDynamicFontSize = unclampedDynamicFontSize.clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );
    final double dynamicLineHeight = baseLineHeight;
    const double tightLineHeight = 1.5;
    // --- End Responsive Scaling ---

    // --- Dynamic Padding Calculation ---
    final double availableWidth = screenWidth - (2 * pageHorizontalPadding);
    double dynamicLinePadding = 0.0;
    if (availableWidth > maxLineContentWidth) {
      dynamicLinePadding = (availableWidth - maxLineContentWidth) / 2.0;
    }
    // --- End Dynamic Padding Calculation ---

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
              (unclampedDynamicFontSize * surahNameScaleFactor).clamp(
                minSurahNameFontSize,
                maxSurahNameFontSize,
              );
          final double headerFontSize =
              (unclampedDynamicFontSize * headerScaleFactor).clamp(
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
                  height: tightLineHeight,
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: headerFontSize,
                  height: tightLineHeight,
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
              (unclampedDynamicFontSize * basmallahScaleFactor).clamp(
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
              height: tightLineHeight,
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

          // WHY: Determine visibility word by word based on wordsToShow set.
          if (!line.isCentered) {
            final List<Widget> wordWidgets = line.words.map((word) {
              // WHY: Visibility is true if the word is in the set passed from parent.
              final bool isVisible = wordsToShow.contains(word);

              // WHY: Use AnimatedSwitcher for fade effect.
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  word.text,
                  key: ValueKey(
                    "${word.text}-$isVisible",
                  ), // Key includes visibility
                  style: _getWordStyle(
                    fontSize: defaultDynamicFontSize,
                    lineHeight: dynamicLineHeight, // Ayah line height
                    baseColor: baseTextColor,
                    isVisible: isVisible, // Pass calculated visibility
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
              );
            }).toList();

            lineWidget = Padding(
              padding: EdgeInsets.symmetric(horizontal: dynamicLinePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: wordWidgets,
              ),
            );
          } else {
            // WHY: Centered lines use RichText (no animation per word).
            final List<TextSpan> spans = line.words.map((word) {
              final bool isVisible = wordsToShow.contains(word);
              return TextSpan(
                text: "${word.text} ", // Add space
                style: _getWordStyle(
                  fontSize: defaultDynamicFontSize,
                  lineHeight: dynamicLineHeight, // Ayah line height
                  baseColor: baseTextColor,
                  isVisible: isVisible,
                ),
              );
            }).toList();

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

    // WHY: Non-ayah lines return directly. Ayah lines have visibility handled internally.
    return lineWidget;
  }
}
