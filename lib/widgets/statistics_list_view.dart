import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models.dart';
import '../utils/helpers.dart';
import 'statistics_cards.dart';

class StatisticsListView extends ConsumerWidget {
  const StatisticsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(readingStatisticsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.totalPagesRead == 0 && stats.totalReadingDays == 0) {
          return _EmptyStatisticsState();
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            OverallProgressCard(stats: stats),
            TodayCard(stats: stats),
            ThisWeekCard(stats: stats),
            ThisMonthCard(stats: stats),
            StreakCard(stats: stats),
            AllTimeCard(stats: stats),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل الإحصائيات',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStatisticsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد إحصائيات بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ القراءة لتتبع تقدمك!',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

