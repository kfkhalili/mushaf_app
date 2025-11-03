import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                              'اللون الأساسي',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Consumer(
                              builder: (context, ref, _) {
                                final currentColorValue = ref.watch(
                                  primaryColorProvider,
                                );
                                final currentColor = Color(currentColorValue);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Color Presets Grid
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 5,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                            childAspectRatio: 1.0,
                                          ),
                                      itemCount:
                                          PrimaryColorConstants.presets.length,
                                      itemBuilder: (context, index) {
                                        final preset = PrimaryColorConstants
                                            .presets[index];
                                        final isSelected =
                                            currentColorValue == preset.color;

                                        return GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(
                                                  primaryColorProvider.notifier,
                                                )
                                                .setPrimaryColor(preset.color);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: preset.colorValue,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? theme
                                                          .colorScheme
                                                          .onPrimary
                                                    : Colors.grey.withValues(
                                                        alpha: 0.3,
                                                      ),
                                                width: isSelected ? 3 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: preset.colorValue
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check,
                                                    color: theme
                                                        .colorScheme
                                                        .onPrimary,
                                                    size: 20,
                                                  )
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    // Current Color Preview - Entire row is tappable
                                    InkWell(
                                      onTap: () async {
                                        final pickedColor =
                                            await showDialog<Color>(
                                              context: context,
                                              builder: (context) =>
                                                  _ColorPickerDialog(
                                                    initialColor: currentColor,
                                                  ),
                                            );
                                        if (pickedColor != null) {
                                          ref
                                              .read(
                                                primaryColorProvider.notifier,
                                              )
                                              .setPrimaryColor(
                                                pickedColor.toARGB32(),
                                              );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: currentColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: currentColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: currentColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _getColorName(
                                                  currentColorValue,
                                                ),
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                            Icon(
                                              Icons.color_lens,
                                              color: currentColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
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
                            Consumer(
                              builder: (context, ref, _) {
                                final allLayoutsInfoAsync = ref.watch(
                                  allLayoutsInfoProvider,
                                );
                                final currentLayout = ref.watch(
                                  mushafLayoutSettingProvider,
                                );

                                return allLayoutsInfoAsync.when(
                                  data: (allLayoutsInfo) {
                                    final currentLayoutInfo =
                                        allLayoutsInfo[currentLayout];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InputDecorator(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<MushafLayout>(
                                              value: currentLayout,
                                              isExpanded: true,
                                              items: MushafLayout.values.map((
                                                layout,
                                              ) {
                                                // WHY: Use database name from info table for all layouts
                                                final info =
                                                    allLayoutsInfo[layout];
                                                final displayText =
                                                    info?.name ??
                                                    layout.displayName;
                                                return DropdownMenuItem(
                                                  value: layout,
                                                  child: Text(displayText),
                                                );
                                              }).toList(),
                                              onChanged: (MushafLayout? layout) async {
                                                if (layout != null) {
                                                  // WHY: Await setLayout to ensure state updates before invalidating
                                                  await ref
                                                      .read(
                                                        mushafLayoutSettingProvider
                                                            .notifier,
                                                      )
                                                      .setLayout(layout);
                                                  // WHY: Invalidate allLayoutsInfoProvider to refresh all layout info
                                                  ref.invalidate(
                                                    allLayoutsInfoProvider,
                                                  );
                                                  // WHY: DatabaseServiceProvider watches mushafLayoutSettingProvider,
                                                  // so it will rebuild automatically. We still invalidate pageDataProvider
                                                  // to force rerender with new layout and font.
                                                  ref.invalidate(
                                                    pageDataProvider,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        if (currentLayoutInfo != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'عدد الأسطر في الصفحة: ${convertToEasternArabicNumerals(currentLayoutInfo.linesPerPage.toString())}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                  loading: () => InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<MushafLayout>(
                                        value: currentLayout,
                                        isExpanded: true,
                                        items: MushafLayout.values.map((
                                          layout,
                                        ) {
                                          return DropdownMenuItem(
                                            value: layout,
                                            child: Text(layout.displayName),
                                          );
                                        }).toList(),
                                        onChanged: (MushafLayout? layout) async {
                                          if (layout != null) {
                                            await ref
                                                .read(
                                                  mushafLayoutSettingProvider
                                                      .notifier,
                                                )
                                                .setLayout(layout);
                                            ref.invalidate(
                                              allLayoutsInfoProvider,
                                            );
                                            ref.invalidate(pageDataProvider);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  error: (error, stack) => InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<MushafLayout>(
                                        value: currentLayout,
                                        isExpanded: true,
                                        items: MushafLayout.values.map((
                                          layout,
                                        ) {
                                          return DropdownMenuItem(
                                            value: layout,
                                            child: Text(layout.displayName),
                                          );
                                        }).toList(),
                                        onChanged: (MushafLayout? layout) async {
                                          if (layout != null) {
                                            await ref
                                                .read(
                                                  mushafLayoutSettingProvider
                                                      .notifier,
                                                )
                                                .setLayout(layout);
                                            ref.invalidate(
                                              allLayoutsInfoProvider,
                                            );
                                            ref.invalidate(pageDataProvider);
                                          }
                                        },
                                      ),
                                    ),
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

  // WHY: Helper function to get color name from value or preset
  String _getColorName(int colorValue) {
    final preset = PrimaryColorConstants.presets.firstWhere(
      (p) => p.color == colorValue,
      orElse: () => const ColorPreset(name: 'مخصص', color: 0),
    );
    return preset.name != 'مخصص' ? preset.name : 'لون مخصص';
  }
}

// WHY: Dialog widget for custom color picker using HSV color picker
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _selectedHsv;

  @override
  void initState() {
    super.initState();
    _selectedHsv = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentColor = _selectedHsv.toColor();

    return AlertDialog(
      title: const Text('اختيار لون مخصص'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HSV Color Picker using sliders
            SizedBox(
              height: 280,
              child: Column(
                children: [
                  // Hue Slider
                  Text('اللون', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  _buildColorSlider(
                    value: _selectedHsv.hue / 360,
                    onChanged: (value) {
                      setState(() {
                        _selectedHsv = _selectedHsv.withHue(value * 360);
                      });
                    },
                    color: HSVColor.fromAHSV(
                      1.0,
                      _selectedHsv.hue,
                      1.0,
                      1.0,
                    ).toColor(),
                  ),
                  const SizedBox(height: 16),
                  // Saturation Slider
                  Text('التشبع', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  _buildColorSlider(
                    value: _selectedHsv.saturation,
                    onChanged: (value) {
                      setState(() {
                        _selectedHsv = _selectedHsv.withSaturation(value);
                      });
                    },
                    color: HSVColor.fromAHSV(
                      1.0,
                      _selectedHsv.hue,
                      1.0,
                      _selectedHsv.value,
                    ).toColor(),
                  ),
                  const SizedBox(height: 16),
                  // Value/Brightness Slider
                  Text('السطوع', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  _buildColorSlider(
                    value: _selectedHsv.value,
                    onChanged: (value) {
                      setState(() {
                        _selectedHsv = _selectedHsv.withValue(value);
                      });
                    },
                    color: HSVColor.fromAHSV(
                      1.0,
                      _selectedHsv.hue,
                      _selectedHsv.saturation,
                      1.0,
                    ).toColor(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(currentColor),
          child: const Text('تطبيق'),
        ),
      ],
    );
  }

  Widget _buildColorSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Slider(value: value, onChanged: onChanged, activeColor: color),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
      ],
    );
  }
}
