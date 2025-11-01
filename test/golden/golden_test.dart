import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_app/screens/selection_screen.dart';
import 'package:mushaf_app/screens/settings_screen.dart';
import 'package:mushaf_app/themes.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('Golden Tests - Visual Regression Testing', () {
    // Mock data for golden tests (empty lists to show loading states or minimal data)
    final mockSurahs = <SurahInfo>[];
    final mockJuzs = <JuzInfo>[];

    // Helper to pump widget with provider scope and mocked providers
    Future<void> pumpApp(
      WidgetTester tester,
      Widget child, {
      bool mockDatabase = false,
    }) async {
      // ignore: avoid_annotating_with_dynamic
      dynamic overrides = <Never>[];

      if (mockDatabase) {
        // Mock database-dependent providers for SelectionScreen
        // ignore: argument_type_not_assignable
        overrides = [
          surahListProvider.overrideWith((ref) => Future.value(mockSurahs)),
          juzListProvider.overrideWith((ref) => Future.value(mockJuzs)),
          pagePreviewProvider.overrideWith(
            (ref, pageNumber) => Future.value(''),
          ),
          pageFontFamilyProvider.overrideWith(
            (ref, pageNumber) => Future.value('Uthmani'),
          ),
        ];
      }

      await tester.pumpWidgetBuilder(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: overrides,
          child: MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            home: child,
          ),
        ),
        surfaceSize: const Size(428, 926), // Reference iPhone size
      );
      // Use timed pump instead of pumpAndSettle to avoid timeouts with async data loading
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    setUpAll(() async {
      // Load fonts for golden tests
      await loadAppFonts();
      // Set mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    testGoldens('SelectionScreen - Surah Tab (Light Theme)', (tester) async {
      await pumpApp(tester, const SelectionScreen(), mockDatabase: true);
      await screenMatchesGolden(tester, 'selection_screen_surah_light');
    });

    testGoldens('SelectionScreen - Juz Tab (Light Theme)', (tester) async {
      await pumpApp(tester, const SelectionScreen(), mockDatabase: true);
      // Tap Juz tab
      await tester.tap(find.text('الأجزاء'));
      // Use timed pump instead of pumpAndSettle to avoid timeouts
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await screenMatchesGolden(tester, 'selection_screen_juz_light');
    });

    testGoldens('SelectionScreen - Pages Tab (Light Theme)', (tester) async {
      await pumpApp(tester, const SelectionScreen(), mockDatabase: true);
      // Tap Pages tab
      await tester.tap(find.text('الصفحات'));
      // Use timed pump instead of pumpAndSettle to avoid timeouts
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await screenMatchesGolden(tester, 'selection_screen_pages_light');
    });

    testGoldens('SettingsScreen - Light Theme', (tester) async {
      await pumpApp(tester, const SettingsScreen(), mockDatabase: false);
      await screenMatchesGolden(tester, 'settings_screen_light');
    });

    testGoldens('SettingsScreen - Dark Theme', (tester) async {
      await tester.pumpWidgetBuilder(
        ProviderScope(
          child: MaterialApp(theme: darkTheme, home: const SettingsScreen()),
        ),
        surfaceSize: const Size(428, 926),
      );
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'settings_screen_dark');
    });

    testGoldens('SettingsScreen - Sepia Theme', (tester) async {
      await tester.pumpWidgetBuilder(
        ProviderScope(
          child: MaterialApp(theme: sepiaTheme, home: const SettingsScreen()),
        ),
        surfaceSize: const Size(428, 926),
      );
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'settings_screen_sepia');
    });

    // Note: MushafScreen golden tests require database initialization
    // These should be integration tests instead
  });
}
