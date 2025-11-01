import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_app/main.dart';

/// Helper to pump app with ProviderScope for testing
// ignore: avoid_annotating_with_dynamic
Future<void> pumpApp(
  WidgetTester tester, {
  Widget? home,
  @Deprecated('Use list of Override directly') dynamic overrides,
  Map<String, Object>? prefsValues,
}) async {
  SharedPreferences.setMockInitialValues(prefsValues ?? {});

  // ignore: argument_type_not_assignable
  await tester.pumpWidget(
    ProviderScope(
      // Override type is not exported but is correct at runtime
      overrides: overrides ?? <Never>[],
      child: MaterialApp(home: home ?? const MushafApp()),
    ),
  );

  // Allow initial frames
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// Helper to create test ProviderContainer with overrides
// ignore: avoid_annotating_with_dynamic, argument_type_not_assignable
ProviderContainer createTestContainer({dynamic overrides}) {
  // Override type is not exported but is correct at runtime
  return ProviderContainer(overrides: overrides ?? <Never>[]);
}

/// Helper to wait for async provider updates
Future<void> waitForProvider<T>(
  WidgetTester tester,
  Provider<T> provider,
) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// Helper to verify golden test image matches
Future<void> verifyGolden(WidgetTester tester, String goldenName) async {
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('goldens/$goldenName.png'),
  );
}
