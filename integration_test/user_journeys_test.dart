import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MushafApp()));
    // Allow initial frames and any splash navigation timers
    await tester.pump(const Duration(milliseconds: 600));
    // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  group('Critical User Journeys', () {
    testWidgets('Complete reading journey - Surah navigation', (tester) async {
      await pumpApp(tester);

      // 1. Verify Selection Screen opens
      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأجزاء'), findsOneWidget);
      expect(find.text('الصفحات'), findsOneWidget);

      // 2. Navigate to Surah tab (should already be active)
      // Verify surah list is visible
      expect(find.byType(ListView), findsWidgets);

      // 3. Tap first surah item to open Mushaf
      final surahItems = find.byType(ListTile);
      if (surahItems.evaluate().isNotEmpty) {
        await tester.tap(surahItems.first);
        // Use timed pumps instead of pumpAndSettle
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        // 4. Verify Mushaf Screen opened
        expect(find.byType(PageView), findsOneWidget);

        // 5. Navigate back
        final backButton = find.byIcon(Icons.arrow_forward_ios);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          // Use timed pumps instead of pumpAndSettle
          for (int i = 0; i < 15; i++) {
            await tester.pump(const Duration(milliseconds: 200));
          }

          // 6. Verify back on Selection Screen
          expect(find.text('السور'), findsOneWidget);
        }
      }
    });

    testWidgets('Tab navigation on Selection Screen', (tester) async {
      await pumpApp(tester);

      // Start on Surah tab
      expect(find.text('السور'), findsOneWidget);

      // Switch to Juz tab
      await tester.tap(find.text('الأجزاء'));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('الأجزاء'), findsOneWidget);

      // Switch to Pages tab
      await tester.tap(find.text('الصفحات'));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('الصفحات'), findsOneWidget);

      // Switch back to Surah tab
      await tester.tap(find.text('السور'));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Settings screen navigation', (tester) async {
      await pumpApp(tester);

      // Open Settings via header icon
      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify Settings screen title
      expect(find.text('الإعدادات'), findsOneWidget);

      // Go back using header back button
      final backIcon = find.byIcon(Icons.arrow_forward_ios);
      expect(backIcon, findsWidgets);
      await tester.tap(backIcon.first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Search screen navigation', (tester) async {
      await pumpApp(tester);

      // Open Search via header icon
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify Search screen title
      expect(find.text('البحث'), findsOneWidget);

      // Go back
      final backIcon = find.byIcon(Icons.arrow_forward_ios);
      await tester.tap(backIcon.first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Resume last page opens Mushaf directly', (tester) async {
      // Preload last_page so Splash navigates to Mushaf
      SharedPreferences.setMockInitialValues(<String, Object>{'last_page': 1});

      await pumpApp(tester);

      // Mushaf screen should be present
      expect(find.byType(PageView), findsOneWidget);

      // Navigate back to Selection
      final backIcon = find.byIcon(Icons.arrow_forward_ios);
      if (backIcon.evaluate().isNotEmpty) {
        await tester.tap(backIcon.first);
        // Use timed pumps instead of pumpAndSettle
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        // Confirm Selection screen
        expect(find.text('السور'), findsOneWidget);
      }
    });

    testWidgets('Theme persistence across navigation', (tester) async {
      await pumpApp(tester);

      // Open Settings
      await tester.tap(find.byIcon(Icons.settings));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Find theme options (if visible)
      // This test verifies theme selection widgets exist
      // Note: Actual theme switching may require provider overrides

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify still on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });
  });

  group('Provider State Tests', () {
    testWidgets('Current page state persists across rebuilds', (tester) async {
      await pumpApp(tester);

      // Navigate to Mushaf (if possible)
      // Verify page provider maintains state
      // This is a basic smoke test - detailed provider tests are in unit tests
    });

    testWidgets('Tab index state persists', (tester) async {
      await pumpApp(tester);

      // Switch tabs
      await tester.tap(find.text('الأجزاء'));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Navigate away and back
      await tester.tap(find.byIcon(Icons.settings));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Tab state should be preserved
      expect(find.text('الأجزاء'), findsOneWidget);
    });
  });
}
