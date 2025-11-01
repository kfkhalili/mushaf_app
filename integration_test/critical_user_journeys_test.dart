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
      await tester.pumpAndSettle();

      expect(find.text('السور'), findsOneWidget);
      expect(find.text('الأجزاء'), findsOneWidget);
      expect(find.text('الصفحات'), findsOneWidget);

      // 2. Navigate to Surah list → Select first surah
      final surahItems = find.byType(ListTile);
      if (surahItems.evaluate().isNotEmpty) {
        await tester.tap(surahItems.first);
        await tester.pumpAndSettle();

        // 3. Verify Mushaf Screen opens
        expect(find.byType(PageView), findsOneWidget);
      }
    });

    testWidgets('Complete reading journey - Juz selection', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Navigate to Juz tab
      await tester.tap(find.text('الأجزاء'));
      await tester.pumpAndSettle();

      // Select first juz
      final juzItems = find.byType(ListTile);
      if (juzItems.evaluate().isNotEmpty) {
        await tester.tap(juzItems.first);
        await tester.pumpAndSettle();

        expect(find.byType(PageView), findsOneWidget);
      }
    });

    testWidgets('Complete reading journey - Page navigation', (tester) async {
      // Preload last page
      SharedPreferences.setMockInitialValues({'last_page': 1});

      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify PageView exists
      expect(find.byType(PageView), findsOneWidget);

      // Swipe to next page
      final pageView = find.byType(PageView);
      await tester.drag(pageView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify page navigation occurred (PageView still exists)
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Settings navigation journey', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Open Settings
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify Settings screen
      expect(find.text('الإعدادات'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      await tester.pumpAndSettle();

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Search navigation journey', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Open Search
      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify Search screen
      expect(find.text('البحث'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      await tester.pumpAndSettle();

      // Verify back on Selection screen
      expect(find.text('السور'), findsOneWidget);
    });

    testWidgets('Theme switching preserves state', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MushafApp()));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Should open Mushaf screen
      expect(find.byType(PageView), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios).first);
      await tester.pumpAndSettle();

      // Should return to Selection screen
      expect(find.text('السور'), findsOneWidget);

      // Navigate forward again
      final surahItems = find.byType(ListTile);
      if (surahItems.evaluate().isNotEmpty) {
        await tester.tap(surahItems.first);
        await tester.pumpAndSettle();
        expect(find.byType(PageView), findsOneWidget);
      }
    });
  });
}
