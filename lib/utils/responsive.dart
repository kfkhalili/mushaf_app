import 'package:flutter/material.dart';
import '../constants.dart';

/// Material 3 window size classes, derived from the available width.
///
/// WHY: Form-factor adaptivity should key off *how much space is available now*
/// (so it works for tablets, desktop windows, split-screen and foldables alike),
/// not device type. These are the canonical Material 3 breakpoints. This is the
/// foundation for adaptive chrome (e.g. a navigation rail on [expanded]+); the
/// reading surface itself is already form-factor-proof via PageFit.
enum WindowSizeClass {
  compact, // phones in portrait        (< 600)
  medium, // large phones / small tablets (600–839)
  expanded, // tablets                   (840–1199)
  large, // desktop                      (1200–1599)
  extraLarge; // large desktop           (>= 1600)

  static WindowSizeClass fromWidth(double width) {
    if (width < 600) return WindowSizeClass.compact;
    if (width < 840) return WindowSizeClass.medium;
    if (width < 1200) return WindowSizeClass.expanded;
    if (width < 1600) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }

  /// Reads the current size class from the nearest [MediaQuery] width.
  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// True for tablet-and-up widths, where multi-pane / rail chrome makes sense.
  bool get isExpandedOrWider => index >= WindowSizeClass.expanded.index;
}

class ResponsiveMetrics {
  final double scaleFactor;

  const ResponsiveMetrics({required this.scaleFactor});

  static ResponsiveMetrics of(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double widthScale = size.width / referenceScreenWidth;
    final double heightScale = size.height / referenceScreenHeight;
    final double scaleFactor = widthScale < heightScale
        ? widthScale
        : heightScale;
    return ResponsiveMetrics(scaleFactor: scaleFactor);
  }

  double footerFontSize(double base) => base * scaleFactor;

  EdgeInsets pagePadding({double top = 0}) => EdgeInsets.only(
    top: top,
    bottom: pageBottomPadding * scaleFactor,
    left: pageHorizontalPadding,
    right: pageHorizontalPadding,
  );

  EdgeInsets footerPadding() => EdgeInsets.only(
    bottom: footerBottomPadding * scaleFactor,
    right: footerRightPadding,
    left: footerLeftPadding,
  );
}
