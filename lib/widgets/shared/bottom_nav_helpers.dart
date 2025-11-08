import 'package:flutter/material.dart';
import '../../constants.dart';

/// Shared helper functions for bottom navigation widgets.
///
/// These functions extract common patterns used by both SelectionBottomNav
/// and MushafBottomNav to maintain DRY principles.
class BottomNavHelpers {
  /// Creates a standard BottomAppBar with consistent styling.
  ///
  /// This is used by both selection and mushaf navigation bars.
  static Widget buildBottomAppBar({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return BottomAppBar(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.zero,
      height: kBottomNavBarHeight,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(height: kBottomNavBarHeight, child: child),
    );
  }

  /// Gets the unselected icon color based on theme.
  static Color getUnselectedIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  /// Gets the selected icon color based on theme.
  static Color getSelectedIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.primary;
  }

  /// Gets the unselected text color based on theme.
  static Color getUnselectedTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  /// Creates a standard IconButton with consistent styling for bottom nav.
  static Widget buildNavIconButton({
    required BuildContext context,
    required Icon icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
    EdgeInsets? padding,
  }) {
    final defaultColor = color ?? getUnselectedIconColor(context);
    return SizedBox(
      height: kBottomNavBarHeight,
      child: IconButton(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
        color: defaultColor,
        padding: padding ?? EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
