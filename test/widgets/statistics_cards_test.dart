import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/statistics_cards.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/providers.dart';

import '../support/harness.dart';

void main() {
  group('StatisticsCards', () {
    testWidgets('OverallProgressCard renders correctly', (tester) async {
      final stats = ReadingStatistics(
        totalPagesRead: 100,
        totalReadingDays: 10,
        pagesToday: 5,
        pagesThisWeek: 20,
        pagesThisMonth: 80,
        daysThisWeek: 7,
        daysThisMonth: 10,
        currentStreak: 3,
        longestStreak: 7,
        averagePagesPerDay: 10.0,
      );

      await pumpScreen(
        tester,
        Scaffold(body: OverallProgressCard(stats: stats)),
        overrides: [
          totalPagesProvider.overrideWith((ref) => Future.value(604)),
        ],
      );

      await settle(tester);

      expect(find.text('التقدم الإجمالي'), findsOneWidget);
    });

    testWidgets('TodayCard renders correctly', (tester) async {
      final stats = ReadingStatistics(
        totalPagesRead: 100,
        totalReadingDays: 10,
        pagesToday: 5,
        pagesThisWeek: 20,
        pagesThisMonth: 80,
        daysThisWeek: 7,
        daysThisMonth: 10,
        currentStreak: 3,
        longestStreak: 7,
        averagePagesPerDay: 10.0,
      );

      await pumpScreen(tester, Scaffold(body: TodayCard(stats: stats)));

      expect(find.byType(TodayCard), findsOneWidget);
    });

    testWidgets('ThisWeekCard renders correctly', (tester) async {
      final stats = ReadingStatistics(
        totalPagesRead: 100,
        totalReadingDays: 10,
        pagesToday: 5,
        pagesThisWeek: 20,
        pagesThisMonth: 80,
        daysThisWeek: 7,
        daysThisMonth: 10,
        currentStreak: 3,
        longestStreak: 7,
        averagePagesPerDay: 10.0,
      );

      await pumpScreen(tester, Scaffold(body: ThisWeekCard(stats: stats)));

      expect(find.byType(ThisWeekCard), findsOneWidget);
    });

    testWidgets('handles zero values', (tester) async {
      final stats = ReadingStatistics(
        totalPagesRead: 0,
        totalReadingDays: 0,
        pagesToday: 0,
        pagesThisWeek: 0,
        pagesThisMonth: 0,
        daysThisWeek: 0,
        daysThisMonth: 0,
        currentStreak: 0,
        longestStreak: 0,
        averagePagesPerDay: 0.0,
      );

      await pumpScreen(
        tester,
        Scaffold(body: OverallProgressCard(stats: stats)),
        overrides: [
          totalPagesProvider.overrideWith((ref) => Future.value(604)),
        ],
      );

      await settle(tester);

      expect(find.byType(OverallProgressCard), findsOneWidget);
    });
  });
}
