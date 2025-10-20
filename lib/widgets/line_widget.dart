import 'package:flutter/material.dart';
import '../models.dart';
import '../constants.dart';

class LineWidget extends StatelessWidget {
  final LineInfo line;
  final String pageFontFamily;

  const LineWidget({
    super.key,
    required this.line,
    required this.pageFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    // --- Responsive Font Size Calculation ---
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / referenceScreenWidth;
    double defaultDynamicFontSize = (baseFontSize * scaleFactor).clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );
    const double currentLineHeight = defaultLineHeight;

    // --- Widget to be returned ---
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
                  height: currentLineHeight,
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: headerFontSize,
                  height: currentLineHeight,
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
            ],
          );
          break; // Break the switch case
        } // End case 'surah_name'

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
              height: currentLineHeight,
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break; // Break the switch case
        }
      case 'ayah':
        {
          // WHY: For non-centered ayah lines, we build a Row to manually
          // achieve justification. Centered lines still use a single Text widget.
          if (line.isCentered || line.words.isEmpty) {
            final String textToShow = line.words.map((w) => w.text).join(' ');
            lineContent = Text(
              textToShow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: pageFontFamily,
                fontSize: defaultDynamicFontSize,
                height: currentLineHeight,
              ),
              textScaler: const TextScaler.linear(1.0),
            );
          } else {
            // Build a Row for justified lines
            lineContent = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: line.words.map((word) {
                return Text(
                  word.text,
                  style: TextStyle(
                    fontFamily: pageFontFamily,
                    fontSize: defaultDynamicFontSize,
                    height: currentLineHeight,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                );
              }).toList(),
            );
          }
          break; // Break the switch case
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
