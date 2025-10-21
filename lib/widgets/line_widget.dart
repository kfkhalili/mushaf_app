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
    String? fontFamily = fallbackFontFamily;
    TextAlign lineAlignment = line.isCentered
        ? TextAlign.center
        : TextAlign.justify;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / referenceScreenWidth;
    double defaultDynamicFontSize = (baseFontSize * scaleFactor).clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );

    // WHY: We calculate a dynamic line height based on the screen width,
    // just like the font size. This ensures that the vertical spacing
    // scales proportionally across different devices.
    final double dynamicLineHeight = (baseLineHeight * scaleFactor).clamp(
      minLineHeight,
      maxLineHeight,
    );

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
                  height: dynamicLineHeight, // Apply dynamic height
                ),
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
              ),
              Text(
                headerText,
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: headerFontSize,
                  height: dynamicLineHeight, // Apply dynamic height
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
              height: dynamicLineHeight, // Apply dynamic height
            ),
            textScaler: const TextScaler.linear(1.0),
          );
          break;
        }
      case 'ayah':
        {
          if (line.isCentered || line.words.isEmpty) {
            final String textToShow = line.words.map((w) => w.text).join(' ');
            lineWidget = Text(
              textToShow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: pageFontFamily,
                fontSize: defaultDynamicFontSize,
                height: dynamicLineHeight, // Apply dynamic height
              ),
              textScaler: const TextScaler.linear(1.0),
            );
          } else {
            lineWidget = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: line.words.map((word) {
                return Text(
                  word.text,
                  style: TextStyle(
                    fontFamily: pageFontFamily,
                    fontSize: defaultDynamicFontSize,
                    height: dynamicLineHeight, // Apply dynamic height
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
          lineWidget = const SizedBox.shrink();
          break;
        }
    }

    return lineWidget;
  }
}
