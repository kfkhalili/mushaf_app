import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../screens/mushaf_screen.dart'; // Import to get memorizationProvider

class MushafBottomMenu extends ConsumerWidget {
  final VoidCallback onBackButtonPressed;

  const MushafBottomMenu({super.key, required this.onBackButtonPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentTheme = ref.watch(themeProvider);
    final bool isMemorizing = ref
        .watch(memorizationProvider)
        .isMemorizationMode;
    // WHY: Get theme for primary color and default icon color.
    final theme = Theme.of(context);
    // WHY: Use a grey similar to the unselected color in SelectionScreen.
    final Color unselectedIconColor = Colors.grey.shade400;
    // WHY: Get the primary color for the selected state.
    final Color selectedIconColor = theme.colorScheme.primary;

    const double barHeight = 64.0; // Keep consistent height
    const double iconSize = 30.0;

    return BottomAppBar(
      color: const Color(0xFF212121), // Keep the dark background
      padding: EdgeInsets.zero,
      height: barHeight,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: barHeight,
        // WHY: Set a default UNSELECTED icon color for the bar.
        // Icons that need selection state will override this.
        child: IconTheme(
          data: IconThemeData(color: unselectedIconColor, size: iconSize),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- Left-aligned buttons ---
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: barHeight,
                    child: PopupMenuButton<AppThemeMode>(
                      // Uses default unselected color from IconTheme
                      icon: const Icon(Icons.more_vert),
                      onSelected: (AppThemeMode mode) {
                        ref.read(themeProvider.notifier).setTheme(mode);
                      },
                      padding: EdgeInsets.zero,
                      tooltip: 'More options',
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<AppThemeMode>>[
                            CheckedPopupMenuItem<AppThemeMode>(
                              value: AppThemeMode.light,
                              checked: currentTheme == AppThemeMode.light,
                              child: const Text('Light'),
                            ),
                            CheckedPopupMenuItem<AppThemeMode>(
                              value: AppThemeMode.dark,
                              checked: currentTheme == AppThemeMode.dark,
                              child: const Text('Dark'),
                            ),
                            CheckedPopupMenuItem<AppThemeMode>(
                              value: AppThemeMode.sepia,
                              checked: currentTheme == AppThemeMode.sepia,
                              child: const Text('Sepia'),
                            ),
                            const PopupMenuDivider(),
                            CheckedPopupMenuItem<AppThemeMode>(
                              value: AppThemeMode.system,
                              checked: currentTheme == AppThemeMode.system,
                              child: const Text('Auto (System)'),
                            ),
                          ],
                    ),
                  ),
                  SizedBox(
                    height: barHeight,
                    child: IconButton(
                      tooltip: isMemorizing
                          ? 'Exit Memorization'
                          : 'Memorization Mode',
                      // WHY: Conditionally set color based on memorization state.
                      color: isMemorizing
                          ? selectedIconColor
                          : unselectedIconColor,
                      icon: Icon(
                        isMemorizing ? Icons.school : Icons.school_outlined,
                      ),
                      onPressed: () {
                        ref.read(memorizationProvider.notifier).toggleMode();
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              // --- Right-aligned button ---
              SizedBox(
                height: barHeight,
                child: IconButton(
                  tooltip: 'Back',
                  // Uses default unselected color
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: onBackButtonPressed,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
