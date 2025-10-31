import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/juz_list_view.dart';
import '../widgets/surah_list_view.dart';
import '../widgets/page_list_view.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../screens/bookmarks_screen.dart';
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
    // WHY: Order matches RTL tab order: Surah (rightmost), Juz, Pages (leftmost)
    _preloadedViews = [
      const SurahListView(), // 0: Surahs (rightmost in RTL)
      const JuzListView(), // 1: Juz (middle)
      const PageListView(), // 2: Pages (leftmost in RTL)
    ];

    // Initialize PageController (3 tabs: Surah=0, Juz=1, Pages=2)
    // Default to Surah tab (index 0) - rightmost in RTL
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getScreenTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return ''; // Surahs
      case 1:
        return ''; // Juz
      case 2:
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
              onBookmarkPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                );
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                reverse: true,
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
