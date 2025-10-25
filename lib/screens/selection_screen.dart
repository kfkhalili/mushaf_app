import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/juz_list_view.dart';
import '../widgets/surah_list_view.dart';
import '../widgets/page_list_view.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../providers.dart';

class SelectionScreen extends ConsumerStatefulWidget {
  const SelectionScreen({super.key});

  @override
  ConsumerState<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends ConsumerState<SelectionScreen> {
  Widget _buildCurrentView(int currentIndex) {
    switch (currentIndex) {
      case 0: // Page
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
    final currentIndex = ref.watch(selectionTabIndexProvider);

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
            Expanded(child: _buildCurrentView(currentIndex)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        type: AppBottomNavigationType.selection,
        selectedIndex: currentIndex,
        onIndexChanged: (index) {
          ref.read(selectionTabIndexProvider.notifier).setTabIndex(index);
        },
      ),
    );
  }
}
