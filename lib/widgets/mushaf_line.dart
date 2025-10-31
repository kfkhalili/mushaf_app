import 'dart:math'; // For min()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../constants.dart';
import '../providers.dart';
import '../utils/helpers.dart';

class MushafLine extends ConsumerWidget {
  final LineInfo line;
  final String pageFontFamily;
  final bool isMemorizationMode;
  // WHY: Accept the set of words that should be visible.
  final Set<Word> wordsToShow;
  // Optional per-ayah hidden state map (key: 003:255)
  final Map<String, bool>? ayahIsHidden;
  // Current ayah index for showing placeholder
  final int? currentAyahIndex;

  const MushafLine({
    super.key,
    required this.line,
    required this.pageFontFamily,
    required this.isMemorizationMode,
    required this.wordsToShow, // Use this set to determine visibility
    this.ayahIsHidden,
    this.currentAyahIndex,
  });

  // WHY: Simplified style helper - only needs visibility flag.
  TextStyle _getWordStyle({
    required double fontSize,
    required double lineHeight,
    required Color baseColor,
    required double opacity,
  }) {
    // Clamp opacity between 0 and 1; apply via withValues per project rule
    final double clamped = opacity.clamp(0.0, 1.0);
    final Color wordColor = baseColor.withValues(alpha: clamped);

    return TextStyle(
      fontFamily: pageFontFamily,
      fontSize: fontSize,
      height: lineHeight,
      color: wordColor,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Get user's preferred font size
    final double userFontSize = ref.watch(fontSizeSettingProvider);
    final double unclampedDynamicFontSize = userFontSize * scaleFactor;
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

          // Check if current ayah is hidden for placeholder
          bool showPlaceholder = false;
          if (isMemorizationMode && ayahIsHidden != null && line.words.isNotEmpty) {
            final firstWord = line.words.first;
            if (firstWord.ayahNumber > 0) {
              final key = generateAyahKey(
                firstWord.surahNumber,
                firstWord.ayahNumber,
              );
              showPlaceholder = ayahIsHidden![key] ?? false;
            }
          }

          // Show placeholder if ayah is hidden
          if (showPlaceholder && isMemorizationMode) {
            lineWidget = Padding(
              padding: EdgeInsets.symmetric(horizontal: dynamicLinePadding),
              child: Container(
                height: defaultDynamicFontSize * dynamicLineHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: baseTextColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '━━━━━━━━━━━━━━━━━━━━',
                    style: TextStyle(
                      color: baseTextColor.withValues(alpha: 0.5),
                      fontSize: defaultDynamicFontSize * 0.8,
                    ),
                    textDirection: TextDirection.rtl,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
              ),
            );
          } else {
            // Determine per-word visibility using wordsToShow when in memorization mode
            if (!line.isCentered) {
              final List<Widget> wordWidgets = line.words.map((word) {
                bool isVisible = true;
                if (isMemorizationMode) {
                  isVisible = wordsToShow.contains(word);
                }

                if (!isVisible) {
                  return const SizedBox.shrink();
                }

                // WHY: Use AnimatedSwitcher for smooth transitions.
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    word.text,
                    key: ValueKey("${word.text}-${isVisible}"),
                    style: _getWordStyle(
                      fontSize: defaultDynamicFontSize,
                      lineHeight: dynamicLineHeight,
                      baseColor: baseTextColor,
                      opacity: 1.0,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                );
              }).where((w) => w is! SizedBox).toList();

              lineWidget = Padding(
                padding: EdgeInsets.symmetric(horizontal: dynamicLinePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: wordWidgets,
                ),
              );
            } else {
              // WHY: Centered lines use RichText.
              final List<TextSpan> spans = line.words
                  .where((word) => !isMemorizationMode || wordsToShow.contains(word))
                  .map((word) {
                return TextSpan(
                  text: "${word.text} ", // Add space
                  style: _getWordStyle(
                    fontSize: defaultDynamicFontSize,
                    lineHeight: dynamicLineHeight,
                    baseColor: baseTextColor,
                    opacity: 1.0,
                  ),
                );
              }).toList();

              lineWidget = Text.rich(
                TextSpan(children: spans),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
              );
            }
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


