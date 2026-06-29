import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';

class MushafLine extends ConsumerWidget {
  final LineInfo line;
  final String pageFontFamily;
  // WHY: The body font size, sized by [MushafPage] to fill the column width
  // (so word spacing stays tight). Shared by every line on the page.
  final double bodyFontSize;
  // WHY: The line-box height as a multiple of the font size — the font's own
  // natural leading, measured by [MushafPage] (not a hardcoded per-layout
  // constant). The grid's `Expanded` rows provide the inter-line spacing.
  final double lineHeight;
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
    required this.bodyFontSize,
    required this.lineHeight,
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
    // WHY: Honor the OS "reduce motion" accessibility setting — skip the
    // per-word reveal animation when the user has asked to minimize motion.
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    final String basmallahFontFamily = quranCommonFontFamily;

    // --- Layout-driven sizing ---
    // WHY: [bodyFontSize] fills the column width; [lineHeight] is the font's own
    // natural leading (both measured by [MushafPage]). The page's Expanded grid
    // supplies the inter-line spacing, so there's no per-layout leading constant.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dynamicLineHeight = lineHeight;
    const double tightLineHeight = ornamentLineHeight;
    // --- End Layout-driven sizing ---

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

          final double surahNameFontSize = (bodyFontSize * surahNameScaleFactor)
              .clamp(minSurahNameFontSize, maxSurahNameFontSize);
          final double headerFontSize = (bodyFontSize * headerScaleFactor)
              .clamp(minSurahHeaderFontSize, maxSurahHeaderFontSize);

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
          final double basmallahFontSize = (bodyFontSize * basmallahScaleFactor)
              .clamp(minBasmallahFontSize, maxBasmallahFontSize);

          lineWidget = Text(
            textToShow,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: basmallahFontFamily,
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
            final primaryColor = theme.colorScheme.primary;
            final highlightColor = isSelected || isBookmarked
                ? primaryColor
                : baseTextColor;
            Widget widget = Text(
              word.text,
              key: ValueKey(
                "${word.text}-${opacity.toStringAsFixed(2)}-$isSelected-${primaryColor.toARGB32()}",
              ),
              style: _getWordStyle(
                fontSize: bodyFontSize,
                lineHeight: dynamicLineHeight,
                baseColor: highlightColor,
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
              duration: reduceMotion ? Duration.zero : AppDurations.medium,
              child: widget,
            );
          }).toList();

          // WHY: Distribute the line's horizontal slack into the inter-word
          // spaces (word-spacing justification). This keeps every glyph's shape
          // intact — the priority for Quran calligraphy — while filling both
          // margins. The alternatives are worse: horizontally scaling the line
          // to fill distorts the letterforms, and natural spacing leaves a
          // ragged edge. Flutter can't justify a single line and the fonts' own
          // kashida isn't reachable via Flutter text shaping, so this is the
          // least-bad fill. Centered lines (is_centered) center at natural size.
          List<Widget> finalChildren;
          if (line.isCentered) {
            finalChildren = [];
            for (int i = 0; i < wordWidgets.length; i++) {
              finalChildren.add(wordWidgets[i]);
              if (i < wordWidgets.length - 1) {
                finalChildren.add(
                  Text(
                    ' ',
                    style: _getWordStyle(
                      fontSize: bodyFontSize,
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
