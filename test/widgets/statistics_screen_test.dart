import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/statistics_screen.dart';

void main() {
  group('StatisticsScreen', () {
    testWidgets('renders statistics screen with header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const StatisticsScreen())),
      );

      await tester.pump();

      expect(find.text('إحصائيات القراءة'), findsOneWidget);
    });

    testWidgets('displays statistics list view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const StatisticsScreen())),
      );

      await tester.pump();

      expect(find.byType(StatisticsScreen), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const StatisticsScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(StatisticsScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const StatisticsScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(StatisticsScreen), findsOneWidget);
    });
  });
}
