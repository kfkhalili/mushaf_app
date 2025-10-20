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
    String textToShow = '';
    TextStyle? specificTextStyle; // Renamed for clarity
    String? fontFamily = 'QPCV2';
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / referenceScreenWidth;
    // This is the BASE dynamic size, used if not overridden below
    double defaultDynamicFontSize = (baseFontSize * scaleFactor).clamp(
      16.0,
      30.0,
    );
    double dynamicLineHeight = 1.8;

    switch (line.lineType) {
      case 'surah_name':
        {
          final String surahNumPadded = line.surahNumber.toString().padLeft(
            3,
            '0',
          );
          // Use your corrected order
          textToShow = 'surah$surahNumPadded surah-icon';
          fontFamily = surahNameFontFamily;
          // Calculate the specific, larger size for Surah names
          final double surahNameFontSize = (defaultDynamicFontSize * 1.5).clamp(
            22.0,
            40.0,
          ); // Increased max clamp
          // Store it in specificTextStyle
          specificTextStyle = TextStyle(
            fontSize: surahNameFontSize, // Use the calculated larger size
          );
          lineAlignment = TextAlign.center;
          break;
        }
      case 'basmallah':
        {
          textToShow = basmallah;
          // Calculate specific size for Basmallah
          final double basmallahFontSize = (defaultDynamicFontSize * 0.95)
              .clamp(15.0, 28.0);
          specificTextStyle = TextStyle(
            fontSize: basmallahFontSize,
          ); // Store it
          lineAlignment = TextAlign.center;
          break;
        }
      case 'ayah':
        {
          textToShow = line.words.map((w) => w.text).join(' ');
          fontFamily = pageFontFamily;
          // No specificTextStyle needed, will use defaultDynamicFontSize
          break;
        }
      default:
        {
          textToShow = '';
          break;
        }
    }

    // --- Corrected Style Application ---
    // If a specificTextStyle was created (Surah Name, Basmallah), use it.
    // Otherwise, create a default TextStyle using the base dynamic size.
    final TextStyle finalTextStyle =
        specificTextStyle?.copyWith(
          fontFamily: fontFamily, // Apply correct font family
          height: dynamicLineHeight,
        ) ??
        TextStyle(
          fontFamily: fontFamily,
          fontSize: defaultDynamicFontSize, // Use the default calculated size
          height: dynamicLineHeight,
        );

    return Text(
      textToShow,
      textDirection: TextDirection.rtl,
      textAlign: lineAlignment,
      style: finalTextStyle, // Apply the correctly determined style
      textScaler: const TextScaler.linear(1.0),
    );
  }
}
