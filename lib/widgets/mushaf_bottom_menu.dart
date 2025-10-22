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
    final theme = Theme.of(context);

    // WHY: Set the desired height. Try 44.0 for a noticeable difference.
    const double barHeight = 64.0;
    const double iconSize = 30.0; // Standard icon size

    return BottomAppBar(
      color: const Color(0xFF212121),
      padding: EdgeInsets.zero,
      // WHY: Set the height directly on the BottomAppBar *as well as* the SizedBox.
      height: barHeight,
      // WHY: Helps ensure content respects the bounds.
      clipBehavior: Clip.antiAlias,
      // WHY: Use SizedBox to explicitly control the overall height of the content area.
      child: SizedBox(
        height: barHeight,
        child: IconTheme(
          data: IconThemeData(color: theme.colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center icons vertically
            children: <Widget>[
              // --- Left-aligned buttons ---
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center vertically
                children: [
                  // WHY: Constrain the vertical space the button takes.
                  SizedBox(
                    height: barHeight, // Use barHeight
                    child: PopupMenuButton<AppThemeMode>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (AppThemeMode mode) {
                        ref.read(themeProvider.notifier).setTheme(mode);
                      },
                      padding: EdgeInsets.zero,
                      tooltip: 'More options',
                      iconSize: iconSize,
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
                  // WHY: Constrain the vertical space the button takes.
                  SizedBox(
                    height: barHeight, // Use barHeight
                    child: IconButton(
                      tooltip: 'Bookmark',
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        /* Placeholder */
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      iconSize: iconSize,
                    ),
                  ),
                  // WHY: Constrain the vertical space the button takes.
                  SizedBox(
                    height: barHeight, // Use barHeight
                    child: IconButton(
                      tooltip: isMemorizing
                          ? 'Exit Memorization'
                          : 'Memorization Mode',
                      icon: Icon(
                        isMemorizing ? Icons.school : Icons.school_outlined,
                      ),
                      onPressed: () {
                        ref.read(memorizationProvider.notifier).toggleMode();
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      iconSize: iconSize,
                    ),
                  ),
                ],
              ),
              // --- Right-aligned button ---
              // WHY: Constrain the vertical space the button takes.
              SizedBox(
                height: barHeight, // Use barHeight
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: onBackButtonPressed,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  iconSize: iconSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
