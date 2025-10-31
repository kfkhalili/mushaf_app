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
  // Optional per-ayah opacity map (key: 003:255)
  final Map<String, double>? ayahOpacities;
  // Callback for long-press on ayah word
  final Function(int surahNumber, int ayahNumber, Offset position)?
  onAyahLongPress;
  // Selected ayah key for highlighting (key: 003:255)
  final String? selectedAyahKey;
  // Set of bookmarked ayah keys on the current page
  final Set<String>? bookmarkedAyahKeys;

  const MushafLine({
    super.key,
    required this.line,
    required this.pageFontFamily,
    required this.isMemorizationMode,
    required this.wordsToShow, // Use this set to determine visibility
    this.ayahOpacities,
    this.onAyahLongPress,
    this.selectedAyahKey,
    this.bookmarkedAyahKeys,
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

          // Unified logic for both centered and non-centered lines
          final List<Widget> wordWidgets = line.words.asMap().entries.map((
            entry,
          ) {
            final word = entry.value;
            double opacity = 1.0;
            final wordKey = generateAyahKey(word.surahNumber, word.ayahNumber);
            final isSelected = selectedAyahKey == wordKey;
            final isBookmarked = bookmarkedAyahKeys?.contains(wordKey) ?? false;

            if (isMemorizationMode) {
              if (!wordsToShow.contains(word)) {
                opacity = 0.0;
              } else if (ayahOpacities != null) {
                opacity = ayahOpacities![wordKey] ?? 1.0;
              }
            }

            // Base text widget
            Widget widget = Text(
              word.text,
              key: ValueKey(
                "${word.text}-${opacity.toStringAsFixed(2)}-$isSelected",
              ),
              style: _getWordStyle(
                fontSize: defaultDynamicFontSize,
                lineHeight: dynamicLineHeight,
                baseColor: isSelected || isBookmarked
                    ? theme.colorScheme.primary
                    : baseTextColor,
                opacity: opacity,
              ),
              textScaler: const TextScaler.linear(1.0),
            );

            // Add long-press gesture detection
            if (onAyahLongPress != null && word.ayahNumber > 0) {
              widget = GestureDetector(
                onLongPress: () {
                  final RenderBox? renderBox =
                      context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final localPosition = renderBox.localToGlobal(Offset.zero);
                    onAyahLongPress!(
                      word.surahNumber,
                      word.ayahNumber,
                      localPosition,
                    );
                  }
                },
                child: widget,
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget,
            );
          }).toList();

          // For centered lines, add spaces between words
          List<Widget> finalChildren;
          if (line.isCentered) {
            finalChildren = [];
            for (int i = 0; i < wordWidgets.length; i++) {
              finalChildren.add(wordWidgets[i]);
              if (i < wordWidgets.length - 1) {
                finalChildren.add(
                  Text(
                    " ",
                    style: _getWordStyle(
                      fontSize: defaultDynamicFontSize,
                      lineHeight: dynamicLineHeight,
                      baseColor: baseTextColor,
                      opacity: 1.0,
                    ),
                  ),
                );
              }
            }
          } else {
            finalChildren = wordWidgets;
          }

          lineWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: dynamicLinePadding),
            child: Row(
              mainAxisAlignment: line.isCentered
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: finalChildren,
            ),
          );
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
