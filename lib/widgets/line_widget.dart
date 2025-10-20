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
    String textToShow = '';
    TextStyle? textStyle;
    String? fontFamily = 'QPCV2'; // Default fallback font
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    // --- Responsive Font Size Calculation ---
    // Get screen width from MediaQuery
    final double screenWidth = MediaQuery.of(context).size.width;
    // Calculate scaling factor based on reference width from constants.dart
    final double scaleFactor = screenWidth / referenceScreenWidth;
    // Calculate dynamic font size using baseFontSize from constants.dart
    // Clamp the size between a reasonable min and max.
    double dynamicFontSize = (baseFontSize * scaleFactor).clamp(
      16.0,
      30.0,
    ); // e.g., Min 16, Max 30
    // You might want to scale line height too, or keep it fixed
    double dynamicLineHeight = 1.8;

    switch (line.lineType) {
      case 'surah_name':
        {
          textToShow = line.surahName ?? 'Surah';
          // Scale the Surah name font size too, maybe make it slightly larger proportionally
          textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            // Scale up the base size slightly for headers, then apply screen scaling and clamp
            fontSize: (baseFontSize * 1.2 * scaleFactor).clamp(20.0, 34.0),
          );
          lineAlignment = TextAlign.center;
          break;
        }
      case 'basmallah':
        {
          textToShow = basmallah; // Use constant from constants.dart
          // Scale Basmallah size, maybe slightly smaller than base ayah size
          dynamicFontSize = (baseFontSize * 0.95 * scaleFactor).clamp(
            15.0,
            28.0,
          );
          lineAlignment = TextAlign.center;
          break;
        }
      case 'ayah':
        {
          textToShow = line.words.map((w) => w.text).join(' ');
          fontFamily = pageFontFamily; // Use the dynamically loaded page font
          // dynamicFontSize remains as calculated above
          break;
        }
      default:
        {
          textToShow = '';
          break;
        }
    }

    // Apply the calculated dynamic font size and line height
    return Text(
      textToShow,
      textDirection: TextDirection.rtl,
      textAlign: lineAlignment,
      style:
          textStyle?.copyWith(
            fontFamily: fontFamily,
            fontSize: dynamicFontSize, // Use calculated size
            height: dynamicLineHeight,
          ) ??
          TextStyle(
            fontFamily: fontFamily,
            fontSize: dynamicFontSize, // Use calculated size
            height: dynamicLineHeight,
          ),
      // Set textScaler to 1.0 because we are manually calculating the font size.
      // Using MediaQuery's textScaler might interfere.
      textScaler: const TextScaler.linear(1.0),
    );
  }
}
