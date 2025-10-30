import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/mushaf_screen.dart';
import '../../providers/memorization_provider.dart';
import '../../constants.dart';

/// Shared bottom navigation widget that can be used across different screens
/// Supports both selection screen navigation and mushaf screen navigation
class AppBottomNavigation extends ConsumerWidget {
  final AppBottomNavigationType type;
  final VoidCallback? onBackButtonPressed;
  final int? currentPageNumber;
  final int? selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  const AppBottomNavigation({
    super.key,
    required this.type,
    this.onBackButtonPressed,
    this.currentPageNumber,
    this.selectedIndex,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (type == AppBottomNavigationType.mushaf) {
      // WHY: Removed the SizedBox wrapper and Stack.
      // This widget is now only responsible for building the bar itself,
      // which has a fixed height, ensuring consistency.
      return _buildMushafNavigation(context, ref);
    }

    return _buildSelectionNavigation(context, ref);
  }

  Widget _buildSelectionNavigation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return BottomAppBar(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.zero,
      height: kBottomNavBarHeight,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: kBottomNavBarHeight,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: kBottomNavLabelFontSize,
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildSelectionNavItem(
                context,
                index: 0,
                label: 'الصفحات',
                isSelected: selectedIndex == 0,
                onTap: () => onIndexChanged?.call(0),
              ),
              _buildSelectionNavItem(
                context,
                index: 1,
                label: 'الأجزاء',
                isSelected: selectedIndex == 1,
                onTap: () => onIndexChanged?.call(1),
              ),
              _buildSelectionNavItem(
                context,
                index: 2,
                label: 'السور',
                isSelected: selectedIndex == 2,
                onTap: () => onIndexChanged?.call(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final Color color = isSelected
        ? theme.colorScheme.primary
        : (theme.brightness == Brightness.dark
              ? Colors.grey.shade400
              : Colors.grey.shade600);

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, kBottomNavBarHeight),
        foregroundColor: color,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: kBottomNavLabelFontSize, color: color),
      ),
    );
  }

  Widget _buildMushafNavigation(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final Color unselectedIconColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final Color selectedIconColor = theme.colorScheme.primary;

    final bool isMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );

    return BottomAppBar(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.zero,
      height: kBottomNavBarHeight,
      clipBehavior: Clip.antiAlias, // Properly clip content to prevent overlaps
      child: SizedBox(
        height: kBottomNavBarHeight,
        child: IconTheme(
          data: IconThemeData(
            color: unselectedIconColor,
            size: kBottomNavIconSize,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Left Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: _buildMemorizationButton(
                      ref,
                      isMemorizing,
                      selectedIconColor,
                      unselectedIconColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildMemorizationToggleButton(
                      context,
                      ref,
                      selectedIconColor,
                      unselectedIconColor,
                    ),
                  ),
                ],
              ),
              // Right Button
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorizationButton(
    WidgetRef ref,
    bool isMemorizing,
    Color selectedIconColor,
    Color unselectedIconColor,
  ) {
    return SizedBox(
      height: kBottomNavBarHeight,
      child: IconButton(
        tooltip: isMemorizing ? 'Exit Memorization' : 'Memorization Mode',
        color: isMemorizing ? selectedIconColor : unselectedIconColor,
        icon: Icon(isMemorizing ? Icons.school : Icons.school_outlined),
        onPressed: () {
          ref
              .read(memorizationProvider.notifier)
              .toggleMode(currentPageNumber: currentPageNumber);
        },
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      height: kBottomNavBarHeight,
      child: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: onBackButtonPressed,
        padding: const EdgeInsets.only(right: footerRightPadding),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildMemorizationToggleButton(
    BuildContext context,
    WidgetRef ref,
    Color selectedIconColor,
    Color unselectedIconColor,
  ) {
    final session = ref.watch(memorizationSessionProvider);
    final int page = currentPageNumber ?? 1;
    final bool active = session != null && session.pageNumber == page;

    final String tooltip = enableMemorizationBeta
        ? (active ? 'End Memorization (Beta)' : 'Start Memorization (Beta)')
        : 'Memorization (Beta) disabled';
    final Color color = active ? selectedIconColor : unselectedIconColor;

    return SizedBox(
      height: kBottomNavBarHeight,
      child: IconButton(
        tooltip: tooltip,
        color: color,
        icon: Icon(active ? Icons.link : Icons.link_outlined),
        onPressed: () async {
          if (!enableMemorizationBeta) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Memorization (Beta) is disabled')),
            );
            return;
          }
          final notifier = ref.read(memorizationSessionProvider.notifier);
          if (active) {
            await notifier.endSession();
          } else {
            await notifier.startSession(pageNumber: page, firstAyahIndex: 0);
          }
        },
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

enum AppBottomNavigationType { selection, mushaf }
