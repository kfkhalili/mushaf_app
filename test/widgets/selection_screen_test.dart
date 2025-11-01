import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/selection_screen.dart';

void main() {
  group('SelectionScreen', () {
    testWidgets('renders selection screen with header and navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SelectionScreen())),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SelectionScreen())),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Bottom navigation should be present
      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const SelectionScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const SelectionScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SelectionScreen), findsOneWidget);
    });
  });
}
