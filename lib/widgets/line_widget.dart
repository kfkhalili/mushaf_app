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
      16.0,
      30.0,
    );
    double dynamicLineHeight = 1.8;

    // Default Alignment and Font
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;
    String? fontFamily = 'QPCV2'; // Fallback font

    // Specific styling for certain line types
    TextStyle? specificTextStyle;
    String textToShow = '';

    // Widget to be returned - Default is a simple Text widget
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

          final double surahNameFontSize = (defaultDynamicFontSize * 1.5).clamp(
            22.0,
            40.0,
          );
          // Slightly larger font size for the header frame to ensure it encompasses the name
          final double headerFontSize = (surahNameFontSize * 1.5).clamp(
            24.0,
            44.0,
          );

          // Build the Stack for Surah Name and Header
          lineContent = Stack(
            alignment: Alignment.center, // Center both Text widgets
            children: [
              // 1. Surah Name Text (Bottom Layer)
              Text(
                surahNameText,
                style: TextStyle(
                  fontFamily: surahNameFontFamily, // Specific font for name
                  fontSize: surahNameFontSize,
                  height: dynamicLineHeight,
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              // 2. Header Frame Text (Top Layer)
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily, // Specific font for header
                  fontSize: headerFontSize, // Slightly larger size
                  height: dynamicLineHeight,
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
            ],
          );
          // Return the Stack directly for surah_name type
          return lineContent; // Exit build method here for Stack
        } // End case 'surah_name'

      case 'basmallah':
        {
          textToShow = basmallah;
          final double basmallahFontSize = (defaultDynamicFontSize * 0.95)
              .clamp(15.0, 28.0);
          specificTextStyle = TextStyle(fontSize: basmallahFontSize);
          lineAlignment = TextAlign.center;
          // fontFamily remains 'QPCV2' (default)
          break;
        }
      case 'ayah':
        {
          textToShow = line.words.map((w) => w.text).join(' ');
          fontFamily = pageFontFamily; // Use the dynamically loaded page font
          // No specificTextStyle, use defaultDynamicFontSize
          break;
        }
      default:
        {
          textToShow = '';
          break;
        }
    }

    // --- Build standard Text widget for non-surah_name lines ---
    final TextStyle finalTextStyle =
        specificTextStyle?.copyWith(
          fontFamily: fontFamily,
          height: dynamicLineHeight,
        ) ??
        TextStyle(
          fontFamily: fontFamily,
          fontSize: defaultDynamicFontSize,
          height: dynamicLineHeight,
        );

    lineContent = Text(
      textToShow,
      textDirection: TextDirection.rtl,
      textAlign: lineAlignment,
      style: finalTextStyle,
      textScaler: const TextScaler.linear(1.0),
    );

    // Return the standard Text widget
    return lineContent;
  }
}
