import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// legacy riverpod import removed
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../utils/ui_signals.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'dart:collection';
import '../providers/memorization_provider.dart';
import '../widgets/countdown_circle.dart';
// duplicate import removed

// Legacy memorization removed

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

    // Beta session tap handling with auto-advance
    final session = ref.read(memorizationSessionProvider);
    if (session != null && session.pageNumber == currentPage) {
      // Only auto-advance on NEXT tap after the last ayah has already been shown
      // i.e., if we were already on the last ayah BEFORE this tap.
      bool wasOnLastAyahBeforeTap = false;
      final asyncPageData = ref.read(pageDataProvider(currentPage));
      asyncPageData.whenData((PageData pageData) {
        final allQuranWordsOnPage = extractQuranWordsFromPage(pageData.layout);
        final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
          groupWordsByAyahKey(allQuranWordsOnPage),
        );
        final totalAyatOnPage = ayahsOnPageMap.length;
        wasOnLastAyahBeforeTap =
            session.lastAyahIndexShown >= (totalAyatOnPage - 1);

        ref
            .read(memorizationSessionProvider.notifier)
            .onTap(totalAyatOnPage: totalAyatOnPage)
            .then((_) async {
          final updated = ref.read(memorizationSessionProvider);
          if (updated != null && updated.pageNumber == currentPage) {
            // Advance only if we were already at the last ayah BEFORE this tap
            if (wasOnLastAyahBeforeTap) {
              _surahCumulativeEnd += totalAyatOnPage;
              final nextPage = currentPage + 1;
              if (nextPage <= totalPages) {
                _pageController.animateToPage(
                  nextPage - 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
                ref.read(currentPageProvider.notifier).setPage(nextPage);
                await ref
                    .read(memorizationSessionProvider.notifier)
                    .startSession(pageNumber: nextPage, firstAyahIndex: 0);
              }
            }
          }
        });
      });
      return;
    }

    // No legacy fallback
  }


  @override
  Widget build(BuildContext context) {
    // WHY: Watch the global page state.
    final int currentPageNumber = ref.watch(currentPageProvider);

    // Listen for session transitions to reset circle values (inside build)
    ref.listen(memorizationSessionProvider, (prev, next) {
      // On session end: clear range tracking
      if (prev != null && next == null) {
        _surahCumulativeEnd = 0;
        _memorizationStartPage = null;
        _startAyahNumberOnStartPage = null;
        if (mounted) setState(() {});
      }
      // On session start: reset cumulative and compute start ayah m for current page
      if (prev == null && next != null) {
        _surahCumulativeEnd = 0;
        _memorizationStartPage = next.pageNumber;
        final asyncPageData = ref.read(pageDataProvider(next.pageNumber));
        asyncPageData.whenData((PageData pageData) {
          _startAyahNumberOnStartPage = _firstAyahNumberOnPage(pageData);
          if (mounted) setState(() {});
        });
      }
    });

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
      if (_memorizationStartPage == null && isBetaMemorizing) {
        _memorizationStartPage = currentPageNumber;
        _startAyahNumberOnStartPage = _firstAyahNumberOnPage(pageData);
      }
      // Reset start page if mode disabled
      if (!isBetaMemorizing) {
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
                    onHorizontalDragStart: (details) {
                      final session = ref.read(memorizationSessionProvider);
                      final int page = ref.read(currentPageProvider);
                      final bool isBetaMemorizing = enableMemorizationBeta &&
                          session != null &&
                          session.pageNumber == page;
                      if (isBetaMemorizing) {
                        // Flash multiple times to reinforce the hint
                        flashMemorizationIcon(times: 3);
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      final session = ref.read(memorizationSessionProvider);
                      final int page = ref.read(currentPageProvider);
                      final bool isBetaMemorizing = enableMemorizationBeta &&
                          session != null &&
                          session.pageNumber == page;
                      if (isBetaMemorizing) {
                        // absorb gesture by doing nothing and flashing
                        memorizationIconFlashTick.value = memorizationIconFlashTick.value + 1;
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      // WHY: Use the named constant for total page count.
                      itemCount: totalPages,
                      reverse: true,
                      physics: (enableMemorizationBeta && isBetaMemorizing)
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
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
