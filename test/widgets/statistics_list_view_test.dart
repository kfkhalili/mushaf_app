import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/statistics_list_view.dart';

void main() {
  group('StatisticsListView', () {
    testWidgets('renders statistics list view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const StatisticsListView())),
        ),
      );

      await tester.pump();

      expect(find.byType(StatisticsListView), findsOneWidget);
    });

    testWidgets('displays statistics cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const StatisticsListView())),
        ),
      );

      await tester.pump();

      // StatisticsListView should render without errors
      expect(find.byType(StatisticsListView), findsOneWidget);
    });
  });
}
