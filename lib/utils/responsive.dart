import 'package:flutter/material.dart';
import '../constants.dart';

class ResponsiveMetrics {
  final double scaleFactor;
  final double widthScale;
  final double heightScale;

  const ResponsiveMetrics({
    required this.scaleFactor,
    required this.widthScale,
    required this.heightScale,
  });

  static ResponsiveMetrics of(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double widthScale = size.width / referenceScreenWidth;
    final double heightScale = size.height / referenceScreenHeight;
    final double scaleFactor = widthScale < heightScale
        ? widthScale
        : heightScale;
    return ResponsiveMetrics(
      scaleFactor: scaleFactor,
      widthScale: widthScale,
      heightScale: heightScale,
    );
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
