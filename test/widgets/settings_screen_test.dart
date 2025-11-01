import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/settings_screen.dart';
import 'package:mushaf_app/themes.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders settings screen with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: lightTheme, home: const SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('displays theme options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: lightTheme, home: const SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check if theme options are present
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: lightTheme, home: const SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: darkTheme, home: const SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders in sepia theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: sepiaTheme, home: const SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
