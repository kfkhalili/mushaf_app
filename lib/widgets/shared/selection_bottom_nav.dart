import 'package:flutter/material.dart';
import '../../constants.dart';
import 'bottom_nav_helpers.dart';

/// Bottom navigation bar for SelectionScreen.
///
/// Displays tabs for Surah, Juz, and Pages selection.
///
/// Extracted from AppBottomNavigation to maintain separation of concerns
/// while sharing common patterns via BottomNavHelpers.
class SelectionBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  const SelectionBottomNav({
    super.key,
    required this.selectedIndex,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavHelpers.buildBottomAppBar(
      context: context,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: kBottomNavLabelFontSize,
          color: BottomNavHelpers.getUnselectedTextColor(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: <Widget>[
            // WHY: RTL order from right to left: Surah (0), Juz (1), Pages (2)
            _buildNavItem(
              context,
              index: 0,
              label: 'السور',
              isSelected: selectedIndex == 0,
              onTap: () => onIndexChanged?.call(0),
            ),
            _buildNavItem(
              context,
              index: 1,
              label: 'الأجزاء',
              isSelected: selectedIndex == 1,
              onTap: () => onIndexChanged?.call(1),
            ),
            _buildNavItem(
              context,
              index: 2,
              label: 'الصفحات',
              isSelected: selectedIndex == 2,
              onTap: () => onIndexChanged?.call(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final Color color = isSelected
        ? theme.colorScheme.primary
        : BottomNavHelpers.getUnselectedTextColor(context);

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
}
