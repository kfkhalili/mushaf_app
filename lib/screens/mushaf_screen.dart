import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'dart:collection';
import '../providers/memorization_provider.dart';
import '../widgets/countdown_circle.dart';

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

  // Surah-wide cumulative end (sum of fully completed pages' ayah counts)
  int _surahCumulativeEnd = 0;
  int _currentSurahNumber = 0;

  // Track memorization start page to return user back if they wander
  int? _memorizationStartPage;
  // Track the starting ayah number on the start page (for correct range base)
  int? _startAyahNumberOnStartPage;

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

  // Compute the first (minimum) ayah number on a page
  int _firstAyahNumberOnPage(PageData pageData) {
    final allQuranWordsOnPage = extractQuranWordsFromPage(pageData.layout);
    final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
      groupWordsByAyahKey(allQuranWordsOnPage),
    );
    if (ayahsOnPageMap.isEmpty) return 1;
    final firstKey = ayahsOnPageMap.keys.first; // format: "surah:ayah"
    final parts = firstKey.split(':');
    if (parts.length == 2) {
      final ayah = int.tryParse(parts[1]) ?? 1;
      return ayah > 0 ? ayah : 1;
    }
    return 1;
  }

  // Update surah tracking when page or surah changes
  void _maybeResetSurahProgress(PageData pageData) {
    final int pageSurah = pageData.pageSurahNumber;
    if (pageSurah <= 0) return;
    if (_currentSurahNumber != pageSurah) {
      _currentSurahNumber = pageSurah;
      _surahCumulativeEnd = 0; // reset at surah boundary
      // Reset base to first ayah of new page/surah when crossing boundary
      _startAyahNumberOnStartPage = _firstAyahNumberOnPage(pageData);
    }
  }

  void _handleMemorizationTap() {
    final int currentPage = ref.read(currentPageProvider);

    // If user is not on the memorization start page, navigate back there first
    if (_memorizationStartPage != null && currentPage != _memorizationStartPage) {
      _pageController.animateToPage(
        _memorizationStartPage! - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      ref.read(currentPageProvider.notifier).setPage(_memorizationStartPage!);
      return;
    }

    // Beta session tap handling (no auto-advance)
    final session = ref.read(memorizationSessionProvider);
    if (session != null && session.pageNumber == currentPage) {
      final asyncPageData = ref.read(pageDataProvider(currentPage));
      asyncPageData.whenData((PageData pageData) {
        final allQuranWordsOnPage = extractQuranWordsFromPage(pageData.layout);
        final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
          groupWordsByAyahKey(allQuranWordsOnPage),
        );
        final totalAyatOnPage = ayahsOnPageMap.length;
        ref
            .read(memorizationSessionProvider.notifier)
            .onTap(totalAyatOnPage: totalAyatOnPage);
      });
      return;
    }

    // Legacy mode fallback
    _advanceLegacyMemorization();
  }

  void _advanceLegacyMemorization() {
    final int pageNumber = ref.read(currentPageProvider);
    final asyncPageData = ref.read(pageDataProvider(pageNumber));
    asyncPageData.whenData((PageData pageData) {
      final allQuranWordsOnPage = extractQuranWordsFromPage(pageData.layout);
      final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
        groupWordsByAyahKey(allQuranWordsOnPage),
      );
      final orderedKeys = ayahsOnPageMap.keys.toList();
      ref
          .read(memorizationProvider.notifier)
          .revealNextStep(pageNumber, allQuranWordsOnPage, orderedKeys);
    });
  }

  @override
  Widget build(BuildContext context) {
    // WHY: Watch the global page state.
    final int currentPageNumber = ref.watch(currentPageProvider);

    // Legacy memorization mode state (standard)
    final bool isLegacyMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );

    // Beta memorization session state
    final memorizationSession = ref.watch(memorizationSessionProvider);
    final bool isBetaMemorizing =
        enableMemorizationBeta &&
        memorizationSession != null &&
        memorizationSession.pageNumber == currentPageNumber;

    final asyncPageData = ref.watch(pageDataProvider(currentPageNumber));

    // Keep surah state synced
    asyncPageData.whenData(_maybeResetSurahProgress);

    // Capture memorization start page + base ayah if just enabled
    asyncPageData.whenData((pageData) {
      if (_memorizationStartPage == null && (isLegacyMemorizing || isBetaMemorizing)) {
        _memorizationStartPage = currentPageNumber;
        _startAyahNumberOnStartPage = _firstAyahNumberOnPage(pageData);
      }
      // Reset start page if mode disabled
      if (!isLegacyMemorizing && !isBetaMemorizing) {
        _memorizationStartPage = null;
        _startAyahNumberOnStartPage = null;
      }
    });

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
                    error: (_, _) => '',
                  ),
                  onSearchPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Search functionality coming soon'),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: enableMemorizationBeta
                        ? _handleMemorizationTap
                        : null,
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
              if (Navigator.canPop(context)) {
                await _clearLastPage();
                if (isLegacyMemorizing) {
                  ref.read(memorizationProvider.notifier).disableMode();
                }
                if (isBetaMemorizing) {
                  await ref
                      .read(memorizationSessionProvider.notifier)
                      .endSession();
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
          floatingActionButton: null,
        ),
        if (isLegacyMemorizing)
          Positioned(
            // WHY: Position the circle above the bottom navigation bar
            // with a small gap to prevent overlap issues
            bottom: kBottomNavBarHeight + 8.0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                final asyncPageData = ref.watch(
                  pageDataProvider(currentPageNumber),
                );
                String? centerLabel;
                asyncPageData.whenData((pageData) {
                  final allQuranWordsOnPage = extractQuranWordsFromPage(
                    pageData.layout,
                  );
                  final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
                    groupWordsByAyahKey(allQuranWordsOnPage),
                  );
                  final totalAyatOnPage = ayahsOnPageMap.length;
                  final revealedCount =
                      ref.read(memorizationProvider).lastRevealedAyahIndexMap[
                              currentPageNumber] ??
                          0;
                  final visibleEnd = revealedCount.clamp(1, totalAyatOnPage);
                  final cumulativeEnd = _surahCumulativeEnd + visibleEnd;

                  final int startAyah = _startAyahNumberOnStartPage ?? 1;
                  final int endAyah = startAyah + cumulativeEnd - 1;

                  centerLabel = cumulativeEnd <= 1
                      ? convertToEasternArabicNumerals(startAyah.toString())
                      : '${convertToEasternArabicNumerals(startAyah.toString())}–${convertToEasternArabicNumerals(endAyah.toString())}';
                });
                return CountdownCircle(
                  onTap: () => ref
                      .read(memorizationProvider.notifier)
                      .decrementRepetitions(_advanceLegacyMemorization),
                  centerLabel: centerLabel,
                );
              },
            ),
          ),
        if (isBetaMemorizing)
          Positioned(
            bottom: kBottomNavBarHeight + 8.0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                final asyncPageData = ref.watch(
                  pageDataProvider(currentPageNumber),
                );
                String? centerLabel;
                asyncPageData.whenData((pageData) {
                  final session = ref.read(memorizationSessionProvider);
                  if (session != null &&
                      session.pageNumber == currentPageNumber) {
                    final endOnPage = (session.lastAyahIndexShown + 1).clamp(1, 999);
                    final cumulativeEnd = _surahCumulativeEnd + endOnPage;

                    final int startAyah = _startAyahNumberOnStartPage ?? 1;
                    final int endAyah = startAyah + cumulativeEnd - 1;

                    centerLabel = cumulativeEnd <= 1
                        ? convertToEasternArabicNumerals(startAyah.toString())
                        : '${convertToEasternArabicNumerals(startAyah.toString())}–${convertToEasternArabicNumerals(endAyah.toString())}';
                  }
                });
                return CountdownCircle(
                  onTap: _handleMemorizationTap,
                  showNumber: false,
                  centerLabel: centerLabel,
                );
              },
            ),
          ),
      ],
    );
  }
}
