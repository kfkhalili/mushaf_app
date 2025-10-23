import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../screens/mushaf_screen.dart'; // Import to get memorizationProvider

class MushafBottomMenu extends ConsumerWidget {
  final VoidCallback onBackButtonPressed;
  // WHY: Accept the current page number from the parent screen.
  final int currentPageNumber;

  const MushafBottomMenu({
    super.key,
    required this.onBackButtonPressed,
    required this.currentPageNumber, // Add required parameter
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentTheme = ref.watch(themeProvider);
    final bool isMemorizing = ref
        .watch(memorizationProvider)
        .isMemorizationMode;
    final theme = Theme.of(context);
    final Color unselectedIconColor = Colors.grey.shade400;
    final Color selectedIconColor = theme.colorScheme.primary;

    const double barHeight = 48.0;
    const double iconSize = 24.0;

    return BottomAppBar(
      color: const Color(0xFF212121),
      padding: EdgeInsets.zero,
      height: barHeight,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: barHeight,
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
                      /* ... Popup Menu ... */
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
                      /* ... Bookmark Button ... */
                      tooltip: 'Bookmark',
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        /* Placeholder */
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  SizedBox(
                    height: barHeight,
                    child: IconButton(
                      tooltip: isMemorizing
                          ? 'Exit Memorization'
                          : 'Memorization Mode',
                      color: isMemorizing
                          ? selectedIconColor
                          : unselectedIconColor,
                      icon: Icon(
                        isMemorizing ? Icons.school : Icons.school_outlined,
                      ),
                      onPressed: () {
                        // WHY: Pass the current page number when toggling.
                        ref
                            .read(memorizationProvider.notifier)
                            .toggleMode(currentPageNumber: currentPageNumber);
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
                  /* ... Back Button ... */
                  tooltip: 'Back',
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
