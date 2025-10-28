import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/countdown_circle.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'dart:collection';

// --- State Management for Memorization Mode ---
// (MemorizationState and Notifier remain the same)
@immutable
class MemorizationState {
  final bool isMemorizationMode;
  final Map<int, int> lastRevealedAyahIndexMap;
  final int repetitionGoal;
  final int currentRepetitions;
  final bool isTextHidden;

  const MemorizationState({
    this.isMemorizationMode = false,
    this.lastRevealedAyahIndexMap = const {},
    this.repetitionGoal = 5,
    this.currentRepetitions = 0,
    this.isTextHidden = false,
  });

  MemorizationState copyWith({
    bool? isMemorizationMode,
    Map<int, int>? lastRevealedAyahIndexMap,
    int? repetitionGoal,
    int? currentRepetitions,
    bool? isTextHidden,
  }) {
    return MemorizationState(
      isMemorizationMode: isMemorizationMode ?? this.isMemorizationMode,
      lastRevealedAyahIndexMap:
          lastRevealedAyahIndexMap ?? this.lastRevealedAyahIndexMap,
      repetitionGoal: repetitionGoal ?? this.repetitionGoal,
      currentRepetitions: currentRepetitions ?? this.currentRepetitions,
      isTextHidden: isTextHidden ?? this.isTextHidden,
    );
  }
}

class MemorizationNotifier extends StateNotifier<MemorizationState> {
  MemorizationNotifier() : super(const MemorizationState());
  void toggleMode({int? currentPageNumber}) {
    final bool enabling = !state.isMemorizationMode;
    Map<int, int> newMap = const {};
    if (enabling && currentPageNumber != null) {
      newMap = {currentPageNumber: -1};
      state = state.copyWith(currentRepetitions: state.repetitionGoal);
    } else {
      state = state.copyWith(currentRepetitions: 0);
    }
    state = state.copyWith(
      isMemorizationMode: enabling,
      lastRevealedAyahIndexMap: newMap,
      isTextHidden: false,
    );
  }

  void disableMode() {
    if (state.isMemorizationMode) {
      state = state.copyWith(
        isMemorizationMode: false,
        lastRevealedAyahIndexMap: const {},
        currentRepetitions: 0,
        isTextHidden: false,
      );
    }
  }

  void decrementRepetitions(VoidCallback onRevealNext) {
    if (state.currentRepetitions > 1) {
      state = state.copyWith(currentRepetitions: state.currentRepetitions - 1);
    } else {
      if (!state.isTextHidden) {
        state = state.copyWith(
          isTextHidden: true,
          currentRepetitions: state.repetitionGoal,
        );
      } else {
        state = state.copyWith(
          isTextHidden: false,
          currentRepetitions: state.repetitionGoal,
        );
        onRevealNext();
      }
    }
  }

  void setRepetitionGoal(int goal) {
    if (goal > 0) {
      state = state.copyWith(repetitionGoal: goal);
      if (state.isMemorizationMode) {
        state = state.copyWith(currentRepetitions: goal);
      }
    }
  }

  void revealNextStep(
    int pageNumber,
    List<Word> allWords,
    List<String> orderedKeys,
  ) {
    final int currentRevealedAyahCount =
        state.lastRevealedAyahIndexMap[pageNumber] ?? -1;

    // Increment the number of ayahs to reveal (start from 1 if -1)
    final int nextRevealedAyahCount = currentRevealedAyahCount < 0
        ? 2 // If -1 (initial), next should show 2 ayahs
        : currentRevealedAyahCount + 1;

    // Cap the count to the total number of ayahs
    final int finalRevealedAyahCount =
        nextRevealedAyahCount > orderedKeys.length
        ? orderedKeys.length
        : nextRevealedAyahCount;

    final newMap = Map<int, int>.from(state.lastRevealedAyahIndexMap);
    newMap[pageNumber] = finalRevealedAyahCount;
    state = state.copyWith(
      lastRevealedAyahIndexMap: newMap,
      currentRepetitions: state.repetitionGoal,
    );
  }
}

final memorizationProvider =
    StateNotifierProvider<MemorizationNotifier, MemorizationState>(
      (ref) => MemorizationNotifier(),
    );
// --- End State Management ---

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const MushafScreen({super.key, this.initialPage = 1});
  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late final PageController _pageController;

  // WHY: This function is only responsible for persistence.
  Future<void> _savePageToPrefs(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', pageNumber);
  }

  Future<void> _clearLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_page');
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);

    // WHY: Initialize the global page state provider.
    Future.microtask(
      () => ref.read(currentPageProvider.notifier).setPage(widget.initialPage),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleMemorizationTap() {
    final memorizationNotifier = ref.read(memorizationProvider.notifier);
    final memorizationState = ref.read(memorizationProvider);
    if (!memorizationState.isMemorizationMode) return;

    // WHY: Read the current page number directly from the provider.
    final int pageNumber = ref.read(currentPageProvider);

    final asyncPageData = ref.read(pageDataProvider(pageNumber));
    asyncPageData.whenData((PageData pageData) {
      // Use pure functions for functional data processing
      final allQuranWordsOnPage = extractQuranWordsFromPage(pageData.layout);
      final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
        groupWordsByAyahKey(allQuranWordsOnPage),
      );
      final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();
      final int currentIndex =
          memorizationState.lastRevealedAyahIndexMap[pageNumber] ?? -1;
      if (currentIndex >= orderedAyahKeys.length) {
        return; // Already fully revealed
      }
      memorizationNotifier.revealNextStep(
        pageNumber,
        allQuranWordsOnPage,
        orderedAyahKeys,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // WHY: Watch the global page state.
    final int currentPageNumber = ref.watch(currentPageProvider);

    // Read state needed for back button logic AND circle visibility
    final isMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );
    final asyncPageData = ref.watch(pageDataProvider(currentPageNumber));

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                AppHeader(
                  title: asyncPageData.when(
                    data: (pageData) {
                      final String juzGlyphString =
                          'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
                      final String surahNameGlyphString =
                          (pageData.pageSurahNumber > 0)
                          ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
                          : '';

                      // Build the complete title with juz and surah glyphs only
                      String title = juzGlyphString;
                      if (surahNameGlyphString.isNotEmpty) {
                        title += ' $surahNameGlyphString';
                      }
                      return title;
                    },
                    loading: () => '',
                    error: (_, __) => '',
                  ),
                  onSearchPressed: () {
                    // TODO: Implement search functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Search functionality coming soon'),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _handleMemorizationTap,
                    child: PageView.builder(
                      controller: _pageController,
                      // WHY: Use the named constant for total page count.
                      itemCount: totalPages,
                      reverse: true,
                      onPageChanged: (index) {
                        final int newPageNumber = index + 1;
                        // WHY: Update the global state provider.
                        ref
                            .read(currentPageProvider.notifier)
                            .setPage(newPageNumber);
                        _savePageToPrefs(newPageNumber);
                      },
                      itemBuilder: (context, index) {
                        return MushafPageWidget(pageNumber: index + 1);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNavigation(
            type: AppBottomNavigationType.mushaf,
            currentPageNumber: currentPageNumber,
            onBackButtonPressed: () async {
              final memorizationNotifier = ref.read(
                memorizationProvider.notifier,
              );
              if (Navigator.canPop(context)) {
                await _clearLastPage();
                if (isMemorizing) {
                  memorizationNotifier.disableMode();
                }
                if (context.mounted) {
                  // WHY: This line was fixed. It was Navigator.pop(H(context))
                  Navigator.pop(context);
                }
              }
            },
          ),
        ),
        if (isMemorizing)
          Positioned(
            // WHY: Position the circle above the bottom navigation bar
            // with a small gap to prevent overlap issues
            bottom: kBottomNavBarHeight + 8.0,
            left: 0,
            right: 0,
            child: CountdownCircle(
              onTap: () => ref
                  .read(memorizationProvider.notifier)
                  .decrementRepetitions(_handleMemorizationTap),
            ),
          ),
      ],
    );
  }
}
