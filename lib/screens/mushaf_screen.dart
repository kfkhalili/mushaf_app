import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode and debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/shared/app_bottom_navigation.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../utils/ui_signals.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'dart:collection';
import '../widgets/countdown_circle.dart';
// duplicate import removed

// Legacy memorization removed

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const MushafScreen({super.key, this.initialPage = 1});
  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;

  int _currentSurahNumber = 0;

  // Track memorization start page to return user back if they wander
  int? _memorizationStartPage;
  // Deprecated range base tracking removed in favor of per-surah computation

  // WHY: This function is only responsible for persistence.
  Future<void> _savePageToPrefs(int pageNumber) async {
    // WHY: Use sharedPreferencesProvider instead of direct SharedPreferences.getInstance()
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setInt('last_page', pageNumber);
  }

  Future<void> _clearLastPage() async {
    // WHY: Use sharedPreferencesProvider instead of direct SharedPreferences.getInstance()
    final prefs = await ref.read(sharedPreferencesProvider.future);
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

    // WHY: Register lifecycle observer to handle app backgrounding/foregrounding.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // WHY: Remove lifecycle observer when widget is disposed.
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _externalPageUpdate = null; // Reset for next time
    // Page change listener is automatically disposed by Riverpod
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // WHY: Save current page when app goes to background to prevent data loss.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Save current page when app goes to background
      final currentPage = ref.read(currentPageProvider);
      _savePageToPrefs(currentPage);
    }
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
                final bool windowEmpty = updated.window.ayahIndices.isEmpty;
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

  // Track if we're currently animating to prevent conflicts
  bool _isAnimating = false;
  int? _externalPageUpdate; // Track external page updates (from audio)

  // Navigate to a specific page (called from external sources like audio)
  void _navigateToPage(int pageNumber) {
    final targetIndex = pageNumber - 1;

    if (targetIndex < 0 || !_pageController.hasClients) {
      if (kDebugMode) {
        debugPrint(
          'MushafScreen: Cannot navigate - targetIndex=$targetIndex, hasClients=${_pageController.hasClients}',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'MushafScreen: Starting navigation to page $pageNumber (index $targetIndex)',
      );
    }

    // Navigate immediately without delay to ensure it happens as soon as audio starts
    if (mounted && _pageController.hasClients && !_isAnimating) {
      final currentIndex = _pageController.page?.round() ?? -1;
      if (kDebugMode) {
        debugPrint(
          'MushafScreen: Current index=$currentIndex, targetIndex=$targetIndex',
        );
      }
      if (currentIndex != targetIndex && targetIndex >= 0) {
        _isAnimating = true;
        if (kDebugMode) {
          debugPrint('MushafScreen: Animating to page $pageNumber');
        }
        _pageController
            .animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              if (mounted) {
                _isAnimating = false;
                _externalPageUpdate = null; // Clear after animation
                if (kDebugMode) {
                  debugPrint(
                    'MushafScreen: Animation complete to page $pageNumber',
                  );
                }
              }
            })
            .catchError((error) {
              if (mounted) {
                _isAnimating = false;
                _externalPageUpdate = null;
                if (kDebugMode) {
                  debugPrint('MushafScreen: Animation error: $error');
                }
              }
            });
      } else {
        _isAnimating = false;
        _externalPageUpdate = null;
        if (kDebugMode) {
          debugPrint(
            'MushafScreen: Already at target page, skipping animation',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // WHY: Watch the global page state.
    final int currentPageNumber = ref.watch(currentPageProvider);

    // WHY: Listen to currentPageProvider changes for external updates (e.g., from audio)
    // Only animate if the change came from external source (audio config screen)
    // Don't animate if it's from normal navigation, initial load, or user swiping
    ref.listen(currentPageProvider, (previous, next) {
      // Handle page changes (previous != next)
      // If previous is null, it's the initial build - skip
      if (previous == null) return;

      final isPageChange = previous != next;

      // Handle page changes - always navigate when page changes from external source
      if (isPageChange && !_isAnimating && mounted) {
        if (kDebugMode) {
          debugPrint(
            'MushafScreen: Page change detected: $previous -> $next (initialPage: ${widget.initialPage})',
          );
        }

        // Skip if this matches the initial page AND PageController is already there
        // This prevents animations when screen is first created with initialPage
        if (_pageController.hasClients) {
          final currentIndex = _pageController.page?.round() ?? -1;
          final initialIndex = widget.initialPage - 1;
          final targetIndex = next - 1;

          if (kDebugMode) {
            debugPrint(
              'MushafScreen: currentIndex=$currentIndex, initialIndex=$initialIndex, targetIndex=$targetIndex',
            );
          }

          // If target is initial page AND controller is already at initial page AND previous was also initial, skip
          // This is normal navigation (new screen created)
          if (next == widget.initialPage &&
              currentIndex == initialIndex &&
              previous == widget.initialPage) {
            if (kDebugMode) {
              debugPrint(
                'MushafScreen: Skipping - matches initial page and controller position (normal navigation)',
              );
            }
            return;
          }

          // Always navigate if PageController is showing a different page than target
          // For same-page navigation, check if we're coming back from a temporary page
          final shouldNavigate =
              (currentIndex != targetIndex && targetIndex >= 0) ||
              // If we're at target but previous was different (coming back from temp page), navigate
              (currentIndex == targetIndex && previous != next);

          if (shouldNavigate) {
            if (kDebugMode) {
              debugPrint(
                'MushafScreen: Navigating to page $next (external update, alreadyAtTarget: ${currentIndex == targetIndex}, previous: $previous)',
              );
            }
            // Mark as external update to prevent conflicts
            _externalPageUpdate = next;
            _navigateToPage(next);
          } else {
            if (kDebugMode) {
              debugPrint(
                'MushafScreen: Skipping - PageController already at target',
              );
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              'MushafScreen: PageController not ready yet, marking for later',
            );
          }
          // Mark for later when controller is ready
          _externalPageUpdate = next;
        }
      }
    });

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

    // WHY: Combine both whenData callbacks into single callback for better performance.
    // Single callback registration reduces rebuilds and improves code clarity.
    asyncPageData.whenData((pageData) {
      // Keep surah state synced
      _maybeResetSurahProgress(pageData);

      // Capture memorization start page + base ayah if just enabled
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
                      if (pageData.isLoading) {
                        return ''; // Don't show title while loading page data
                      }
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
                      final bool isBetaMemorizing =
                          enableMemorizationBeta &&
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
                      final bool isBetaMemorizing =
                          enableMemorizationBeta &&
                          session != null &&
                          session.pageNumber == page;
                      if (isBetaMemorizing) {
                        // absorb gesture by doing nothing and flashing
                        memorizationIconFlashTick.value =
                            memorizationIconFlashTick.value + 1;
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      // WHY: Use the named constant for total page count.
                      itemCount: totalPages,
                      reverse: true,
                      // WHY: Memory management for PageView:
                      // - Flutter's PageView automatically keeps only a few pages in memory
                      // - Font loading is managed by LRU cache (maxFontCacheSize = 50)
                      // - Pages are automatically disposed when out of viewport
                      physics: (enableMemorizationBeta && isBetaMemorizing)
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        // Don't update provider if we're animating from external change
                        if (_isAnimating && _externalPageUpdate != null) {
                          // Clear the external update flag once animation completes
                          final targetPage = index + 1;
                          if (targetPage == _externalPageUpdate) {
                            _isAnimating = false;
                            _externalPageUpdate = null;
                            return; // Don't update provider, it's already set
                          }
                        }

                        // Clear animation flag if it was set
                        if (_isAnimating) {
                          _isAnimating = false;
                        }

                        final int newPageNumber = index + 1;
                        // WHY: Update the global state provider.
                        ref
                            .read(currentPageProvider.notifier)
                            .setPage(newPageNumber);
                        _savePageToPrefs(newPageNumber);

                        // Record reading progress (fire-and-forget, no await needed)
                        // WHY: Add error handling to prevent silent failures in production
                        ref
                            .read(readingProgressServiceProvider.future)
                            .then(
                              (service) =>
                                  service.recordPageView(newPageNumber),
                            )
                            .catchError((error, stackTrace) {
                              // WHY: Log errors for debugging and monitoring
                              // Silent failures would make statistics inaccurate
                              if (kDebugMode) {
                                debugPrint(
                                  'Failed to record page view for page $newPageNumber: $error',
                                );
                              }
                              // TODO: Consider adding crash analytics reporting here
                              // FirebaseCrashlytics.instance.recordError(error, stackTrace);
                            });
                      },
                      itemBuilder: (context, index) {
                        return MushafPage(pageNumber: index + 1);
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
                    final ayahsOnPageMap =
                        SplayTreeMap<String, List<Word>>.from(
                          groupWordsByAyahKey(allQuranWordsOnPage),
                        );
                    final orderedKeys = ayahsOnPageMap.keys.toList();

                    if (orderedKeys.isNotEmpty) {
                      final int idx = session.lastAyahIndexShown.clamp(
                        0,
                        orderedKeys.length - 1,
                      );
                      final String currentKey =
                          orderedKeys[idx]; // format: sss:aaa
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
                      final String firstKeyOfCurrentSurah =
                          orderedKeys[firstIndexOfCurrentSurah];
                      final int startAyahNumForCurrentSurah =
                          int.tryParse(firstKeyOfCurrentSurah.split(':')[1]) ??
                          1;

                      final String m = convertToEasternArabicNumerals(
                        startAyahNumForCurrentSurah.toString(),
                      );
                      final String n = convertToEasternArabicNumerals(
                        currentAyahNum.toString(),
                      );
                      centerLabel =
                          currentAyahNum <= startAyahNumForCurrentSurah
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
