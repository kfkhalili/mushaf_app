import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart';
import '../utils/page_fit.dart';
import '../utils/responsive.dart';
import '../utils/selectors.dart';
import 'mushaf_line.dart';
import '../constants.dart'; // Import constants
import 'ayah_context_menu.dart';
import 'overlay_mixin.dart';

class MushafPage extends ConsumerStatefulWidget {
  final int pageNumber;

  const MushafPage({super.key, required this.pageNumber});

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> with OverlayMixin {
  Offset? _tapPosition;
  String? _selectedAyahKey; // Track selected ayah for highlighting

  // WHY: Measuring the body font size runs a TextPainter pass over every line,
  // so memoize it. Bookmark/memorization rebuilds don't change the page grid or
  // the box, so they reuse the cached value; it only recomputes when the box,
  // layout, font, or line count actually change.
  String? _fitKey;
  double _bodyFontSize = 0;
  String? _leadingKey;
  double _naturalLeading = 1.4;

  // WHY: Relative vertical weight of each row in the Expanded grid. The body row
  // is the unit; ornament rows are taller (surah-name header frame, basmallah).
  // These are shared across ALL layouts (not per-layout), and drive both the
  // grid's flex and the font's height cap. Empty rows take negligible space.
  static const double _surahNameWeight = 2.0;
  static const double _basmallahWeight = 1.2;

  double _rowWeight(LineInfo line) {
    switch (line.lineType) {
      case 'surah_name':
        return _surahNameWeight;
      case 'basmallah':
        return _basmallahWeight;
      default:
        return line.words.isEmpty ? 0.001 : 1.0;
    }
  }

  // Flex for the line's Expanded row (flex must be a positive int).
  int _rowFlex(LineInfo line) =>
      (_rowWeight(line) * 1000).round().clamp(1, 1 << 20);

  // WHY: The font's own natural line-box height as a multiple of the font size,
  // measured from the page font — this *replaces* the hardcoded per-layout
  // leading. The Expanded grid supplies the inter-line spacing on top of it.
  double _measureNaturalLeading(String fontFamily) {
    if (fontFamily.isEmpty) return 1.4;
    if (fontFamily == _leadingKey) return _naturalLeading;
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: 'بِسْمِ',
        style: TextStyle(fontFamily: fontFamily, fontSize: 100),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
    )..layout();
    final double ratio = (tp.height / 100).clamp(1.0, 3.0);
    tp.dispose();
    _leadingKey = fontFamily;
    _naturalLeading = ratio;
    return ratio;
  }

  // Sizes the body font to fill the column WIDTH (so word spacing stays tight),
  // capped so a line still fits its grid row. The Expanded grid fills the HEIGHT,
  // so the effective leading is availableHeight/N — derived, not a constant.
  double _resolveBodyFontSize({
    required Size box,
    required PageData pageData,
    required MushafLayout layout,
    required double naturalLeading,
  }) {
    final String key =
        '${widget.pageNumber}|${layout.name}|${pageData.pageFontFamily}|'
        '${box.width.toStringAsFixed(1)}x${box.height.toStringAsFixed(1)}|'
        '${pageData.layout.lines.length}|${naturalLeading.toStringAsFixed(3)}';
    if (key == _fitKey) return _bodyFontSize;
    // verticalUnits = Σ(weight) × naturalLeading ⇒ the height ceiling is
    // bodyRowHeight / naturalLeading; PageFit returns min(that, width-fill).
    final double size = PageFit.forPage(
      pageData.layout,
      box: box,
      fontFamily: pageData.pageFontFamily,
      rowUnits: (line) => _rowWeight(line) * naturalLeading,
      verticalSafetyPx: pageFitVerticalEpsilon,
    );
    _fitKey = key;
    _bodyFontSize = size;
    return size;
  }

  void _handleAyahLongPress(int surahNumber, int ayahNumber, Offset position) {
    // Dismiss previous overlay if exists
    _dismissOverlay();

    final selectedKey = generateAyahKey(surahNumber, ayahNumber);
    setState(() {
      _tapPosition = position;
      _selectedAyahKey = selectedKey;
    });

    // Create overlay widget for context menu
    final overlayWidget = AyahContextMenu(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      tapPosition: _tapPosition ?? Offset.zero,
      onDismiss: _dismissOverlay,
    );

    // Show overlay using mixin
    showOverlay(overlayWidget, context);
  }

  void _dismissOverlay() {
    // Use mixin's dismissOverlay to handle overlay removal
    dismissOverlay();
    // Clear widget-specific state
    setState(() {
      _tapPosition = null;
      _selectedAyahKey = null; // Clear highlight when dismissing
    });
  }

  @override
  void dispose() {
    // Mixin's dispose() handles overlay cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCombined = ref.watch(
      pageDataWithBookmarksProvider(widget.pageNumber),
    );
    final session = ref.watch(memorizationSessionProvider);
    final bool isMemorizing =
        session != null && session.pageNumber == widget.pageNumber;
    final layout = ref.watch(mushafLayoutSettingProvider);

    // Legacy memorization removed

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    final metrics = ResponsiveMetrics.of(context);
    final footerTextStyle = TextStyle(
      fontSize: metrics.footerFontSize(16),
      color: textColor,
    );

    return asyncCombined.when(
      data: (combined) {
        final (pageData, bookmarks) = combined;
        // Determine which ayahs on this page are bookmarked
        final pageAyahs = <String>{};
        for (final line in pageData.layout.lines) {
          for (final word in line.words) {
            if (word.ayahNumber > 0) {
              pageAyahs.add(generateAyahKey(word.surahNumber, word.ayahNumber));
            }
          }
        }

        final allBookmarkedKeys = bookmarks
            .map((b) => generateAyahKey(b.surahNumber, b.ayahNumber))
            .toSet();
        final bookmarkedAyahKeysOnPage = pageAyahs.intersection(
          allBookmarkedKeys,
        );

        final visibility = computeMemorizationVisibility(
          pageData.layout,
          isMemorizing ? session : null,
        );

        final pageNum = convertToEasternArabicNumerals(
          widget.pageNumber.toString(),
        );

        return Scaffold(
          body: GestureDetector(
            onTap: _dismissOverlay, // Dismiss overlay on tap outside
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: metrics.pagePadding(top: 0),
                  // WHY: LayoutBuilder gives the real content box (post-padding)
                  // so the body font size is measured against the actual space
                  // available on this form factor — see [PageFit].
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Size box = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      // WHY: Width-fill font (tight word spacing) + Expanded rows
                      // that fill the height (so the leading is availableHeight/N,
                      // derived — and the vertical margin is minimal). The font's
                      // natural leading is measured, not a per-layout constant.
                      final double naturalLeading = _measureNaturalLeading(
                        pageData.pageFontFamily,
                      );
                      final double bodyFontSize = _resolveBodyFontSize(
                        box: box,
                        pageData: pageData,
                        layout: layout,
                        naturalLeading: naturalLeading,
                      );
                      // WHY: The font is pinned by the vertical fit (N lines at
                      // the font's diacritic line-height), so it can't fill the
                      // width. Rather than smear that horizontal slack into loose
                      // word gaps, narrow the reading column to the lines' natural
                      // width: the widest line fills it edge-to-edge, the rest
                      // justify within it tightly, and the leftover is a small,
                      // symmetric side margin (a horizontal letterbox).
                      final double widestAtProbe =
                          PageFit.measureWidestLineWidth(
                            pageData.layout.lines,
                            fontFamily: pageData.pageFontFamily,
                          );
                      final double naturalWidth = widestAtProbe > 0
                          ? widestAtProbe *
                                bodyFontSize /
                                PageFit.measurementProbeSize
                          : box.width;
                      final double contentWidth = naturalWidth.clamp(
                        0.0,
                        box.width,
                      );
                      final grid = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: pageData.layout.lines.map((line) {
                          return Expanded(
                            flex: _rowFlex(line),
                            // Center the line vertically in its row; stretch so the
                            // line still fills the column width for justification.
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MushafLine(
                                  line: line,
                                  pageFontFamily: pageData.pageFontFamily,
                                  bodyFontSize: bodyFontSize,
                                  lineHeight: naturalLeading,
                                  isMemorizationMode: isMemorizing,
                                  wordsToShow: visibility.visibleWords,
                                  ayahOpacities: visibility.ayahOpacity,
                                  onAyahLongPress: _handleAyahLongPress,
                                  selectedAyahKey: _selectedAyahKey,
                                  bookmarkedAyahKeys: bookmarkedAyahKeysOnPage,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                      return Center(
                        child: SizedBox(width: contentWidth, child: grid),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: (widget.pageNumber % 2 != 0)
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Padding(
                    padding: metrics.footerPadding(),
                    child: Text(pageNum, style: footerTextStyle),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(pageHorizontalPadding),
            child: Text(
              'فشل تحميل الصفحة ${convertToEasternArabicNumerals(widget.pageNumber.toString())}.\n\nخطأ: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
