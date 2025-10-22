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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double barHeight = 64.0;
    const double labelFontSize = 22.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                /* ... Title ... */ 'quran',
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
        height: barHeight,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: barHeight,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: labelFontSize,
              color: Colors.grey.shade400,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  /* ... Page Button ... */ onPressed: () =>
                      setState(() => _currentIndex = 0),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 0
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'الصفحات',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 0
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                TextButton(
                  /* ... Juz' Button ... */ onPressed: () =>
                      setState(() => _currentIndex = 1),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 1
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'الأجزاء',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 1
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                TextButton(
                  /* ... Surah Button ... */ onPressed: () =>
                      setState(() => _currentIndex = 2),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 2
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'السور',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 2
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
