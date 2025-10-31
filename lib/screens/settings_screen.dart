import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'statistics_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentTheme = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'الإعدادات',
                onSearchPressed: null, // No search in settings
                showBackButton: true,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Theme Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المظهر',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'السمة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<AppThemeMode>(
                              initialValue: currentTheme,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: AppThemeMode.light,
                                  child: Text('فاتح'),
                                ),
                                DropdownMenuItem(
                                  value: AppThemeMode.dark,
                                  child: Text('داكن'),
                                ),
                                DropdownMenuItem(
                                  value: AppThemeMode.sepia,
                                  child: Text('بني'),
                                ),
                                DropdownMenuItem(
                                  value: AppThemeMode.system,
                                  child: Text('النظام'),
                                ),
                              ],
                              onChanged: (AppThemeMode? mode) {
                                if (mode != null) {
                                  ref
                                      .read(themeProvider.notifier)
                                      .setTheme(mode);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'تخطيط المصحف',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<MushafLayout>(
                              initialValue: ref.watch(
                                mushafLayoutSettingProvider,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: MushafLayout.values.map((layout) {
                                return DropdownMenuItem(
                                  value: layout,
                                  child: Text(layout.displayName),
                                );
                              }).toList(),
                              onChanged: (MushafLayout? layout) {
                                if (layout != null) {
                                  ref
                                      .read(
                                        mushafLayoutSettingProvider.notifier,
                                      )
                                      .setLayout(layout);
                                  // WHY: Invalidate database service to reload with new layout
                                  ref.invalidate(databaseServiceProvider);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إحصائيات القراءة',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.bar_chart),
                              title: const Text('إحصائيات القراءة'),
                              subtitle: Consumer(
                                builder: (context, ref, _) {
                                  final statsAsync = ref.watch(
                                    readingStatisticsProvider,
                                  );
                                  return statsAsync.when(
                                    data: (stats) => Text(
                                      formatPagesToday(stats.pagesToday),
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                    ),
                                    loading: () =>
                                        const Text('جارٍ التحميل...'),
                                    error: (_, _) => const Text('--'),
                                  );
                                },
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StatisticsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حول',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.info),
                              title: const Text('إصدار التطبيق'),
                              subtitle: const Text('1.0.0'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.help),
                              title: const Text('المساعدة والدعم'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Implement help & support
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Help & support coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
