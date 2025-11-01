import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/utils/navigation.dart';
import 'package:mushaf_app/screens/settings_screen.dart';

void main() {
  group('pushSlideFromLeft', () {
    testWidgets('navigates to screen with slide animation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    pushSlideFromLeft(context, const SettingsScreen());
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pump(); // Start animation
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Middle of animation

      // Navigation should have started
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
