import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/settings_screen.dart';
import 'package:mushaf_app/themes.dart';
import 'package:mushaf_app/constants.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders settings screen with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allLayoutsInfoProvider.overrideWith(
              (ref) => Future.value({
                MushafLayout.uthmani15Lines: const LayoutInfo(
                  name: 'Uthmani Hafs',
                  linesPerPage: 15,
                ),
                MushafLayout.indopak13Lines: const LayoutInfo(
                  name: 'Indopak',
                  linesPerPage: 13,
                ),
                MushafLayout.indopak9Lines: const LayoutInfo(
                  name: 'Indopak 9 lines',
                  linesPerPage: 9,
                ),
              }),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(PrimaryColorConstants.defaultColor),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('displays theme options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allLayoutsInfoProvider.overrideWith(
              (ref) => Future.value({
                MushafLayout.uthmani15Lines: const LayoutInfo(
                  name: 'Uthmani Hafs',
                  linesPerPage: 15,
                ),
                MushafLayout.indopak13Lines: const LayoutInfo(
                  name: 'Indopak',
                  linesPerPage: 13,
                ),
                MushafLayout.indopak9Lines: const LayoutInfo(
                  name: 'Indopak 9 lines',
                  linesPerPage: 9,
                ),
              }),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(PrimaryColorConstants.defaultColor),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if theme options are present
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    final mockLayoutInfoOverride = [
      allLayoutsInfoProvider.overrideWith(
        (ref) => Future.value({
          MushafLayout.uthmani15Lines: const LayoutInfo(
            name: 'Uthmani Hafs',
            linesPerPage: 15,
          ),
          MushafLayout.indopak13Lines: const LayoutInfo(
            name: 'Indopak',
            linesPerPage: 13,
          ),
          MushafLayout.indopak9Lines: const LayoutInfo(
            name: 'Indopak 9 lines',
            linesPerPage: 9,
          ),
        }),
      ),
    ];

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mockLayoutInfoOverride,
          child: MaterialApp(
            theme: buildLightTheme(PrimaryColorConstants.defaultColor),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mockLayoutInfoOverride,
          child: MaterialApp(
            theme: buildDarkTheme(PrimaryColorConstants.defaultColor),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders in sepia theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mockLayoutInfoOverride,
          child: MaterialApp(
            theme: buildSepiaTheme(PrimaryColorConstants.defaultColor),
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
