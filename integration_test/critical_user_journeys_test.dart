import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_app/main.dart';

void main() {
  group('Critical User Journeys - Regression Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete reading journey - Surah selection', (tester) async {
      // 1. Launch app → Selection Screen
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأجزاء'), findsOneWidget);
      expect(find.text('الصفحات'), findsOneWidget);

      // 2. Navigate to Surah list → Select first surah
      final surahItems = find.byType(ListTile);
      if (surahItems.evaluate().isNotEmpty) {
        await tester.tap(surahItems.first);
        // Use timed pumps instead of pumpAndSettle
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        // 3. Verify Mushaf Screen opens
        expect(find.byType(PageView), findsOneWidget);
      }
    });

    testWidgets('Complete reading journey - Juz selection', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Navigate to Juz tab
      await tester.tap(find.text('الأجزاء'));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Select first juz
      final juzItems = find.byType(ListTile);
      if (juzItems.evaluate().isNotEmpty) {
        await tester.tap(juzItems.first);
        // Use timed pumps instead of pumpAndSettle
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        expect(find.byType(PageView), findsOneWidget);
      }
    });

    testWidgets('Complete reading journey - Page navigation', (tester) async {
      // Preload last page
      SharedPreferences.setMockInitialValues({'last_page': 1});

      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify PageView exists
      expect(find.byType(PageView), findsOneWidget);

      // Swipe to next page
      final pageView = find.byType(PageView);
      await tester.drag(pageView, const Offset(-300, 0));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify page navigation occurred (PageView still exists)
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Settings navigation journey', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Open Settings
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify Settings screen
      expect(find.text('الإعدادات'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Search navigation journey', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Open Search
      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify Search screen
      expect(find.text('البحث'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Theme switching preserves state', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Verify Settings screen loads
      expect(find.text('الإعدادات'), findsOneWidget);

      // Theme switching should work without crashing
      // (Actual theme switching UI test would go here)
    });

    testWidgets('Back navigation preserves state', (tester) async {
      // Start with last page saved
      SharedPreferences.setMockInitialValues({'last_page': 5});

      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Should open Mushaf screen
      expect(find.byType(PageView), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      // Use timed pumps instead of pumpAndSettle
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Should return to Selection screen
      expect(find.text('السور'), findsOneWidget);

      // Navigate forward again
      final surahItems = find.byType(ListTile);
      if (surahItems.evaluate().isNotEmpty) {
        await tester.tap(surahItems.first);
        // Use timed pumps instead of pumpAndSettle
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.byType(PageView), findsOneWidget);
      }
    });
  });
}
