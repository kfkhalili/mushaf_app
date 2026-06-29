import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../models.dart';

/// Geometry for fitting a Mushaf page's body text to the available space.
///
/// A Mushaf page is a fixed grid: the layout database dictates how many lines a
/// page has and which words sit on each line (see [PageLayout]). The only free
/// parameter is the body font size, and exactly two things can overflow:
///
///  * **vertically** — the page's rows must fit the available height, and
///  * **horizontally** — the widest line must fit the available width.
///
/// The largest size that avoids both is `min(verticalCeiling, horizontalCeiling)`.
/// Deriving it from the actual page + box makes sizing form-factor independent:
/// there is no reference screen width, no per-layout maximum-size constant, and
/// no clamp — the value is computed, not tuned, and is overflow-proof by
/// construction for any box (phone, tablet, desktop window, split-screen).
///
/// **Vertical units, not line count.** Rows are not all the same height: an
/// ornament row (surah-name frame, basmallah) is taller than a body row because
/// it renders at a larger multiple of the body size. So the vertical ceiling
/// divides the height by the *sum of each row's height multiple* (`verticalUnits`)
/// rather than `lineCount × leading`. A page that is purely body lines has
/// `verticalUnits == lineCount × leading`; ornament-heavy pages (e.g. the three
/// closing surahs on one page) have more, so the body shrinks just enough to fit.
class PageFit {
  // WHY: Private constructor to prevent instantiation — this is a pure helper.
  const PageFit._();

  /// Probe size used for the (linear) width measurement. The returned font size
  /// is independent of this value; `100` just keeps the arithmetic readable.
  static const double measurementProbeSize = 100.0;

  /// The largest uniform body font size at which a page occupying [verticalUnits]
  /// of vertical height-multiple fits [box].
  ///
  /// [verticalUnits] is `Σ` over the page's rows of each row's height relative to
  /// the body font size (a body row contributes its `leading`; an ornament row
  /// its larger multiple). The vertical ceiling is `box.height / verticalUnits`.
  ///
  /// [widestLineWidthAtProbe] is the width of the page's widest body line
  /// measured at [probe] (see [measureWidestLineWidth]); line width scales
  /// linearly with font size, so the horizontal ceiling is
  /// `probe * box.width / widestLineWidthAtProbe`. When it is non-positive (a
  /// page with only ornament rows) the horizontal constraint is ignored.
  /// [verticalSafetyPx] is shaved off the available height before dividing — a
  /// sub-pixel rounding guard (typically one logical pixel) so an exact-fit page
  /// cannot overflow by a fraction of a pixel from TextPainter rounding. It is an
  /// absolute epsilon, not a percentage fudge: rounding error is sub-pixel
  /// regardless of font size, so a fixed pixel is the principled guard.
  static double bodyFontSize({
    required double verticalUnits,
    required double widestLineWidthAtProbe,
    required Size box,
    double probe = measurementProbeSize,
    double verticalSafetyPx = 0.0,
  }) {
    assert(verticalUnits > 0, 'A page always has positive vertical extent');
    assert(probe > 0, 'Probe size must be positive');

    final double usableHeight = math.max(0.0, box.height - verticalSafetyPx);
    final double verticalCeiling = usableHeight / verticalUnits;
    if (widestLineWidthAtProbe <= 0) {
      return math.max(0.0, verticalCeiling);
    }
    final double horizontalCeiling = probe * box.width / widestLineWidthAtProbe;
    return math.max(0.0, math.min(verticalCeiling, horizontalCeiling));
  }

  /// Measures the width of the widest body line (a [LineInfo] that has words) in
  /// [lines] at [probe], using [fontFamily]. Returns `0` when there are no body
  /// lines (e.g. an ornament-only fragment).
  ///
  /// WHY: Each Mushaf line is authored to fill its width at the page's natural
  /// size, so the single widest line governs the horizontal ceiling for the
  /// whole page — sizing to it guarantees no line overflows.
  static double measureWidestLineWidth(
    List<LineInfo> lines, {
    required String fontFamily,
    double probe = measurementProbeSize,
  }) {
    double widest = 0.0;
    for (final LineInfo line in lines) {
      // WHY: surah_name / basmallah rows carry no words and are sized separately.
      if (line.words.isEmpty) continue;
      final String text = line.words.map((Word w) => w.text).join(' ');
      if (text.isEmpty) continue;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontFamily: fontFamily, fontSize: probe),
        ),
        textDirection: TextDirection.rtl,
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    return widest;
  }

  /// Convenience: measures [page] and returns its overflow-proof body font size
  /// in [box], rendered with [fontFamily].
  ///
  /// [rowUnits] returns each row's height multiple relative to the body font size
  /// (body rows → their `leading`; ornament rows → their larger multiple). The
  /// caller owns this mapping because it knows the styling multipliers; [PageFit]
  /// stays pure geometry.
  static double forPage(
    PageLayout page, {
    required Size box,
    required String fontFamily,
    required double Function(LineInfo line) rowUnits,
    double probe = measurementProbeSize,
    double verticalSafetyPx = 0.0,
  }) {
    double verticalUnits = 0.0;
    for (final LineInfo line in page.lines) {
      verticalUnits += rowUnits(line);
    }
    // WHY: An empty/ornamentless fragment still needs a positive divisor.
    if (verticalUnits <= 0) verticalUnits = 1.0;

    final double widest = measureWidestLineWidth(
      page.lines,
      fontFamily: fontFamily,
      probe: probe,
    );
    return bodyFontSize(
      verticalUnits: verticalUnits,
      widestLineWidthAtProbe: widest,
      box: box,
      probe: probe,
      verticalSafetyPx: verticalSafetyPx,
    );
  }
}
