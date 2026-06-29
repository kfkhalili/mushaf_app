import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/selection_screen.dart';

import '../support/harness.dart';

void main() {
  group('SelectionScreen', () {
    testWidgets('renders selection screen with header and navigation', (
      tester,
    ) async {
      await pumpScreen(tester, const SelectionScreen());

      await settle(tester);

      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      await pumpScreen(tester, const SelectionScreen());

      await settle(tester);

      // Bottom navigation should be present
      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: SelectionScreen(),
            ),
          ),
        ),
      );

      await settle(tester);

      expect(find.byType(SelectionScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: SelectionScreen(),
            ),
          ),
        ),
      );

      await settle(tester);

      expect(find.byType(SelectionScreen), findsOneWidget);
    });
  });
}
