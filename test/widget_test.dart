// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mushaf_app/main.dart';

void main() {
  testWidgets('App builds to Selection screen without crashing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ProviderScope(child: MushafApp()));
    // Advance time in chunks instead of pumpAndSettle to avoid timeouts from
    // ongoing animations (e.g., PageView/controller and header transitions).
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    // Basic smoke check: selection tabs are present
    expect(find.text('السور'), findsOneWidget);
    expect(find.text('الأجزاء'), findsOneWidget);
    expect(find.text('الصفحات'), findsOneWidget);
  });
}
