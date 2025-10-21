import 'package:flutter/material.dart';
import '../models.dart';
import '../constants.dart';

class LineWidget extends StatelessWidget {
  final LineInfo line;
  final String pageFontFamily;
  final bool isMemorizationMode;
  final Set<int> visibleWordIds;

  const LineWidget({
    super.key,
    required this.line,
    required this.pageFontFamily,
    this.isMemorizationMode = false, // Default to false
    this.visibleWordIds = const {}, // Default to empty set
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextColor = theme.textTheme.bodyLarge?.color;

    // --- Responsive Font Size Calculation ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / referenceScreenWidth;
    double defaultDynamicFontSize = (baseFontSize * scaleFactor).clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );
    final double dynamicLineHeight = (baseLineHeight * scaleFactor).clamp(
      minLineHeight,
      maxLineHeight,
    );

    Widget lineContent;

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

          lineContent = Stack(
            alignment: Alignment.center,
            children: [
              Text(
                surahNameText,
                style: TextStyle(
                  fontFamily: surahNameFontFamily,
                  fontSize: surahNameFontSize,
                  height: dynamicLineHeight,
                  color: defaultTextColor, // Use theme color
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: headerFontSize,
                  height: dynamicLineHeight,
                  color: defaultTextColor, // Use theme color
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

          lineContent = Text(
            textToShow,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fallbackFontFamily,
              fontSize: basmallahFontSize,
              height: dynamicLineHeight,
              color: defaultTextColor, // Use theme color
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break;
        }
      case 'ayah':
        {
          final lineAlignment = line.isCentered
              ? TextAlign.center
              : TextAlign.justify;

          if (line.isCentered || line.words.isEmpty) {
            final String textToShow = line.words.map((w) => w.text).join(' ');
            lineContent = Text(
              textToShow,
              textAlign: lineAlignment,
              style: TextStyle(
                fontFamily: pageFontFamily,
                fontSize: defaultDynamicFontSize,
                height: dynamicLineHeight,
                // WHY: In memorization mode, centered lines are fully visible or fully transparent.
                // We check the visibility of the first word to decide.
                color:
                    (isMemorizationMode &&
                        line.words.isNotEmpty &&
                        !visibleWordIds.contains(line.words.first.id))
                    ? Colors.transparent
                    : defaultTextColor,
              ),
              textScaler: const TextScaler.linear(1.0),
            );
          } else {
            // Build a Row and apply visibility to each word.
            lineContent = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: line.words.map((word) {
                // WHY: This is the core logic. If in memorization mode, check if the word's
                // ID is in the visible set. If not, make it transparent.
                final color =
                    (isMemorizationMode && !visibleWordIds.contains(word.id))
                    ? Colors.transparent
                    : defaultTextColor;

                return Text(
                  word.text,
                  style: TextStyle(
                    fontFamily: pageFontFamily,
                    fontSize: defaultDynamicFontSize,
                    height: dynamicLineHeight,
                    color: color, // Apply the determined color
                  ),
                  textScaler: const TextScaler.linear(1.0),
                );
              }).toList(),
            );
          }
          break;
        }
      default:
        {
          lineContent = const SizedBox.shrink();
          break;
        }
    }
    return lineContent;
  }
}
