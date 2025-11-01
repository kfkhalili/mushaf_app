import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_app/main.dart';
// ignore_for_file: avoid_redundant_argument_values

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MushafApp()));
    // Allow initial frames and any splash navigation timers
    await tester.pump(const Duration(milliseconds: 600));
    // Use timed pumps instead of pumpAndSettle to avoid timeouts on CI
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('Launch goes to SelectionScreen and opens Settings & Search', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await pumpApp(tester);

    // Verify Selection bottom nav labels exist
    expect(find.text('السور'), findsOneWidget);
    expect(find.text('الأجزاء'), findsOneWidget);
    expect(find.text('الصفحات'), findsOneWidget);

    // Open Settings via header icon
    expect(find.byIcon(Icons.settings), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    // Use timed pumps instead of pumpAndSettle
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Settings title in Arabic
    expect(find.text('الإعدادات'), findsOneWidget);

    // Go back using header back button (arrow)
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    // Use timed pumps instead of pumpAndSettle
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Back on Selection screen
    expect(find.text('السور'), findsOneWidget);

    // Open Search via header icon
    expect(find.byIcon(Icons.search), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    // Use timed pumps instead of pumpAndSettle
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Search title in Arabic
    expect(find.text('البحث'), findsOneWidget);

    // Back again
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    // Use timed pumps instead of pumpAndSettle
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('السور'), findsOneWidget);
  });

  testWidgets('Resume last page opens Mushaf then back returns to Selection', (
    tester,
  ) async {
    // Preload last_page so Splash navigates to Selection then Mushaf
    SharedPreferences.setMockInitialValues(<String, Object>{'last_page': 1});

    await pumpApp(tester);

    // Mushaf screen should be present (Back icon tooltip is 'Back')
    // Find the back IconButton used in the Mushaf bottom nav
    final backIcon = find.byIcon(Icons.arrow_forward_ios);
    expect(backIcon, findsWidgets);

    // Ensure PageView exists
    expect(find.byType(PageView), findsWidgets);

    // Tap back to return to Selection screen
    await tester.tap(backIcon.first);
    // Use timed pumps instead of pumpAndSettle
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Confirm Selection screen labels
    expect(find.text('السور'), findsOneWidget);
    expect(find.text('الأجزاء'), findsOneWidget);
    expect(find.text('الصفحات'), findsOneWidget);
  });
}
