import 'package:flutter/material.dart';
import '../models.dart';
import '../constants.dart'; // Import constants

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

    // Default Alignment and Font
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;
    String? fontFamily = fallbackFontFamily; // Use constant

    // Widget to be returned
    Widget lineWidget; // Renamed for clarity

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

          // Assign the Stack to lineWidget directly
          lineWidget = Stack(
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
          // REMOVED early return statement here
          break; // Break the switch case
        } // End case 'surah_name'

      case 'basmallah':
        {
          const String textToShow = basmallah; // Use constant
          final double basmallahFontSize =
              (defaultDynamicFontSize * basmallahScaleFactor).clamp(
                minBasmallahFontSize,
                maxBasmallahFontSize,
              );
          lineAlignment = TextAlign.center;
          // fontFamily remains fallbackFontFamily

          // Assign the Text widget for Basmallah
          lineWidget = Text(
            textToShow,
            textDirection: TextDirection.rtl,
            textAlign: lineAlignment,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: basmallahFontSize, // Use specific size
              height: currentLineHeight,
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break; // Break the switch case
        }
      case 'ayah':
        {
          final String textToShow = line.words.map((w) => w.text).join(' ');
          fontFamily = pageFontFamily; // Use dynamic page font
          // defaultDynamicFontSize will be used

          // Assign the Text widget for Ayah
          lineWidget = Text(
            textToShow,
            textDirection: TextDirection.rtl,
            textAlign: lineAlignment,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: defaultDynamicFontSize, // Use default dynamic size
              height: currentLineHeight,
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break; // Break the switch case
        }
      default:
        {
          // Assign an empty container or SizedBox for unknown types
          lineWidget = const SizedBox.shrink();
          break; // Break the switch case
        }
    }

    // Return the assigned widget AFTER the switch statement
    return lineWidget;
  }
}
