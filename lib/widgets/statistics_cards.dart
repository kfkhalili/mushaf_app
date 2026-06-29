import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../utils/helpers.dart';
import '../providers.dart';

// Base card style
class _BaseStatCard extends StatelessWidget {
  final Widget child;

  const _BaseStatCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: AppOpacity.faint),
          width: 1,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

// Overall Progress Card
class OverallProgressCard extends ConsumerWidget {
  final ReadingStatistics stats;

  const OverallProgressCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalPagesAsync = ref.watch(totalPagesProvider);

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التقدم الإجمالي',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          totalPagesAsync.when(
            data: (totalPages) {
              final overallProgress = stats.totalPagesRead / totalPages;
              final overallProgressPercent = (overallProgress * 100).round();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        formatPagesProgress(stats.totalPagesRead, totalPages),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        '${convertToEasternArabicNumerals(overallProgressPercent.toString())}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 8,
                      backgroundColor: theme.dividerColor.withValues(
                        alpha: AppOpacity.faint,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading pages: $error')),
          ),
        ],
      ),
    );
  }
}

// Today Card
class TodayCard extends StatelessWidget {
  final ReadingStatistics stats;

  const TodayCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اليوم',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Text(
            formatPagesToday(stats.pagesToday),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// This Week Card
class ThisWeekCard extends StatelessWidget {
  final ReadingStatistics stats;

  const ThisWeekCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averagePages = stats.daysThisWeek > 0
        ? (stats.pagesThisWeek / stats.daysThisWeek).round()
        : 0;

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هذا الأسبوع',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Text(
            formatPages(stats.pagesThisWeek),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            formatDaysOutOf(stats.daysThisWeek, 7),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'متوسط: ${formatPagesPerDay(averagePages)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(
                alpha: AppOpacity.strong,
              ),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// This Month Card
class ThisMonthCard extends StatelessWidget {
  final ReadingStatistics stats;

  const ThisMonthCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averagePages = stats.daysThisMonth > 0
        ? (stats.pagesThisMonth / stats.daysThisMonth).round()
        : 0;

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هذا الشهر',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          Text(
            formatPages(stats.pagesThisMonth),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            formatDays(stats.daysThisMonth),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            'متوسط: ${formatPagesPerDay(averagePages)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(
                alpha: AppOpacity.strong,
              ),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// Streak Card
class StreakCard extends StatelessWidget {
  final ReadingStatistics stats;

  const StreakCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveStreak = stats.currentStreak >= 3;

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              if (hasActiveStreak)
                Text(
                  '🔥 ',
                  style: TextStyle(
                    fontSize: theme.textTheme.titleLarge?.fontSize,
                  ),
                ),
              Text(
                'السلسلة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatDays(stats.currentStreak),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasActiveStreak
                  ? Colors.orange
                  : theme.textTheme.headlineMedium?.color,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          if (hasActiveStreak) ...[
            const SizedBox(height: 8),
            Text(
              'حافظ على السلسلة!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.withValues(alpha: AppOpacity.prominent),
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}

// All-Time Card
class AllTimeCard extends StatelessWidget {
  final ReadingStatistics stats;

  const AllTimeCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجمالي',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'صفحات فريدة',
            value: formatPages(stats.totalPagesRead),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'أيام قراءة',
            value: formatDays(stats.totalReadingDays),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'أطول سلسلة',
            value: formatDays(stats.longestStreak),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _StatRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
