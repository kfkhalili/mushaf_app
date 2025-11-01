import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/utils/responsive.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  group('ResponsiveMetrics', () {
    testWidgets('calculates scale factor correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final metrics = ResponsiveMetrics.of(context);
              expect(metrics.scaleFactor, greaterThan(0));
              expect(metrics.widthScale, greaterThan(0));
              expect(metrics.heightScale, greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('footerFontSize applies scale factor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final metrics = ResponsiveMetrics.of(context);
              final baseSize = 16.0;
              final scaledSize = metrics.footerFontSize(baseSize);
              expect(scaledSize, greaterThan(0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('pagePadding applies scale factor to bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final metrics = ResponsiveMetrics.of(context);
              final padding = metrics.pagePadding();
              expect(padding.bottom, greaterThan(0));
              expect(padding.left, equals(pageHorizontalPadding));
              expect(padding.right, equals(pageHorizontalPadding));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('pagePadding applies top when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final metrics = ResponsiveMetrics.of(context);
              final padding = metrics.pagePadding(top: 10.0);
              expect(padding.top, equals(10.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('footerPadding applies scale factor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final metrics = ResponsiveMetrics.of(context);
              final padding = metrics.footerPadding();
              expect(padding.bottom, greaterThan(0));
              expect(padding.left, equals(footerLeftPadding));
              expect(padding.right, equals(footerRightPadding));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
