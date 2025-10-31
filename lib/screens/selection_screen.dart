import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/juz_list_view.dart';
import '../widgets/surah_list_view.dart';
import '../widgets/page_list_view.dart';
import '../widgets/bookmarks_list_view.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import 'search_screen.dart';

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
      const BookmarksListView(), // 0: Bookmarks (rightmost in RTL)
      const SurahListView(),      // 1: Surahs
      const JuzListView(),        // 2: Juz
      const PageListView(),       // 3: Pages (leftmost in RTL)
    ];

    // Initialize PageController with reverse order (RTL: Bookmarks=0, Surah=1, Juz=2, Pages=3)
    // Default to Surah tab (index 1)
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getScreenTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return ''; // Bookmarks
      case 1:
        return ''; // Surahs
      case 2:
        return ''; // Juz
      case 3:
        return ''; // Pages
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            AppHeader(
              title: _getScreenTitle(currentIndex),
              onSearchPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
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
