import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/juz_list_view.dart';
import '../widgets/surah_list_view.dart';
import '../widgets/page_list_view.dart'; // WHY: Import the new PageListView

class SelectionScreen extends ConsumerStatefulWidget {
  const SelectionScreen({super.key});

  @override
  ConsumerState<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends ConsumerState<SelectionScreen> {
  int _currentIndex = 2; // 0: Page, 1: Juz, 2: Surah
  static const double _barHeight = 64.0;
  static const double _labelFontSize = 22.0;

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0: // Page
        // WHY: Return the PageListView widget.
        return const PageListView();
      case 1: // Juz'
        return const JuzListView();
      case 2: // Surah (Default)
      default:
        return const SurahListView();
    }
  }

  // WHY: Create a helper method to build the navigation buttons.
  // This avoids repeating the TextButton logic.
  Widget _buildNavItem({
    required int index,
    required String label,
    required ThemeData theme,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected
        ? theme.colorScheme.primary
        : Colors.grey.shade400;

    return TextButton(
      onPressed: () => setState(() => _currentIndex = index),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, _barHeight),
        foregroundColor: color,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: _labelFontSize, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'quran',
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Expanded(child: _buildCurrentView()),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF212121),
        padding: EdgeInsets.zero,
        height: _barHeight,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: _barHeight,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: _labelFontSize,
              color: Colors.grey.shade400,
            ),
            // WHY: Use the helper method to build the buttons.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildNavItem(index: 0, label: 'الصفحات', theme: theme),
                _buildNavItem(index: 1, label: 'الأجزاء', theme: theme),
                _buildNavItem(index: 2, label: 'السور', theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
