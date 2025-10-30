import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// legacy riverpod import removed
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page.dart';
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

  int _currentSurahNumber = 0;

  // Track memorization start page to return user back if they wander
  int? _memorizationStartPage;
  // Deprecated range base tracking removed in favor of per-surah computation

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

  // Deprecated helper removed (no longer used)

  // Update surah tracking when page or surah changes
  void _maybeResetSurahProgress(PageData pageData) {
    final int pageSurah = pageData.pageSurahNumber;
    if (pageSurah <= 0) return;
    if (_currentSurahNumber != pageSurah) {
      _currentSurahNumber = pageSurah;
    }
  }

  void _handleMemorizationTap() {
    final int currentPage = ref.read(currentPageProvider);

    // Beta session tap handling with auto-advance
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
            .onTap(totalAyatOnPage: totalAyatOnPage)
            .then((_) async {
          final updated = ref.read(memorizationSessionProvider);
          if (updated != null && updated.pageNumber == currentPage) {
            // Advance only when the last ayah has fully faded out and slid away
            final bool atLastAyah =
                updated.lastAyahIndexShown >= (totalAyatOnPage - 1);
            final bool windowEmpty =
                updated.window.ayahIndices.isEmpty;
            if (atLastAyah && windowEmpty) {
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
        _memorizationStartPage = null;
        if (mounted) setState(() {});
      }
      // On session start: reset cumulative and compute start ayah m for current page
      if (prev == null && next != null) {
        _memorizationStartPage = next.pageNumber;
        if (mounted) setState(() {});
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
      }
      // Reset start page if mode disabled
      if (!isBetaMemorizing) {
        _memorizationStartPage = null;
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
                    // Compute current ayah (n) and starting ayah (m) within the current surah context
                    final allQuranWordsOnPage = extractQuranWordsFromPage(
                      pageData.layout,
                    );
                    final ayahsOnPageMap = SplayTreeMap<String, List<Word>>.from(
                      groupWordsByAyahKey(allQuranWordsOnPage),
                    );
                    final orderedKeys = ayahsOnPageMap.keys.toList();

                    if (orderedKeys.isNotEmpty) {
                      final int idx = session.lastAyahIndexShown.clamp(0, orderedKeys.length - 1);
                      final String currentKey = orderedKeys[idx]; // format: sss:aaa
                      final parts = currentKey.split(':');
                      final int currentSurah = int.tryParse(parts[0]) ?? 0;
                      final int currentAyahNum = int.tryParse(parts[1]) ?? 1;

                      // Find the first ayah index on this page that belongs to currentSurah
                      int firstIndexOfCurrentSurah = 0;
                      for (int i = 0; i < orderedKeys.length; i++) {
                        final p = orderedKeys[i].split(':');
                        final s = int.tryParse(p[0]) ?? -1;
                        if (s == currentSurah) {
                          firstIndexOfCurrentSurah = i;
                          break;
                        }
                      }
                      // Compute starting ayah number m for the current surah on this page
                      final String firstKeyOfCurrentSurah = orderedKeys[firstIndexOfCurrentSurah];
                      final int startAyahNumForCurrentSurah =
                          int.tryParse(firstKeyOfCurrentSurah.split(':')[1]) ?? 1;

                      final String m = convertToEasternArabicNumerals(startAyahNumForCurrentSurah.toString());
                      final String n = convertToEasternArabicNumerals(currentAyahNum.toString());
                      centerLabel = currentAyahNum <= startAyahNumForCurrentSurah
                          ? m
                          : '$m–$n';
                    }
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
