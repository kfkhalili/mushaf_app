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
  late PageController _pageController;
  late final List<Widget> _preloadedViews;

  @override
  void initState() {
    super.initState();
    _preloadedViews = [
      const PageListView(),
      const JuzListView(),
      const SurahListView(),
    ];

    // Initialize PageController with reverse order (Pages=0, Juz=1, Surah=2)
    _pageController = PageController(initialPage: 2);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(selectionTabIndexProvider);

    // Sync PageController with current index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != currentIndex) {
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

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
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref
                      .read(selectionTabIndexProvider.notifier)
                      .setTabIndex(index);
                },
                children: _preloadedViews,
              ),
            ),
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
