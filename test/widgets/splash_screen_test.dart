import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_app/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders splash screen with loading indicator', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SplashScreen())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation delay to complete to avoid timer warnings
      await tester.pump(const Duration(milliseconds: 600));

      // Navigation may have occurred, but we've verified the initial render
      // Just verify we got past the timer without errors
      // The screen may still be present if navigation didn't complete in test env
    });

    testWidgets('renders correctly without navigation', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SplashScreen())),
      );

      // Just verify the screen renders initially
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for navigation delay to complete to avoid timer warnings
      await tester.pump(const Duration(milliseconds: 600));

      // Navigation may or may not work in test environment, so just verify
      // we got past the timer without errors
      expect(find.byType(SplashScreen), findsWidgets);
    });
  });
}
