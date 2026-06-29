// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mushaf_app/main.dart';

import 'support/harness.dart';

void main() {
  useDatabaseTestEnv();

  testWidgets('App builds to Selection screen without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MushafApp()));
    // WHY: pumpAndSettle never settles here (PageView controller + header
    // animations keep scheduling frames); settle a fixed budget instead.
    await settle(tester);

    // Basic smoke check: selection tabs are present
    expect(find.text('السور'), findsOneWidget);
    expect(find.text('الأجزاء'), findsOneWidget);
    expect(find.text('الصفحات'), findsOneWidget);
  });
}
