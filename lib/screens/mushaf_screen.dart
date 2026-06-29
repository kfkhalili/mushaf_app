import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode and debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mushaf_page.dart';
import '../widgets/shared/mushaf_bottom_nav.dart';
import '../widgets/shared/app_header.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/selectors.dart';
import '../utils/navigation.dart';
import '../utils/async_value_helpers.dart';
import '../utils/page_controller_sync_mixin.dart';
import 'bookmarks_screen.dart';
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
    with WidgetsBindingObserver, PageControllerSyncMixin {
  late final PageController _pageController;

  int _currentSurahNumber = 0;
  int?
  _lastKnownTotalPages; // Cache last known totalPages to preserve PageView during loading

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
    // WHY: Use keepPage: true to preserve page position across rebuilds
    // This ensures the PageController maintains its position when PageView is rebuilt
    _pageController = PageController(
      initialPage: widget.initialPage - 1,
      keepPage: true,
    );

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

  /// Generates the title string from PageData.
  ///
  /// Builds a title with juz and surah glyphs for display in the header.
  /// Returns empty string if page data is still loading.
  ///
  /// WHY: Extracted to reduce complexity in build method and improve testability.
  String _generateTitleFromPageData(PageData pageData) {
    if (pageData.isLoading) {
      return ''; // Don't show title while loading page data
    }
    final String juzGlyphString =
        'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
    final String surahNameGlyphString = (pageData.pageSurahNumber > 0)
        ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
        : '';

    // Build the complete title with juz and surah glyphs only
    String title = juzGlyphString;
    if (surahNameGlyphString.isNotEmpty) {
      title += ' $surahNameGlyphString';
    }
    return title;
  }

  void _handleMemorizationTap() {
    final int currentPage = ref.read(currentPageProvider);

    final session = ref.read(memorizationSessionProvider);
    if (session == null || session.pageNumber != currentPage) return;

    // WHY: The session module owns counting ayat, the reveal decision, and the
    // page turn. The widget only forwards the tap with the page it is showing;
    // the resulting advance flows back through currentPageProvider, which this
    // screen already listens to and animates (see _handleExternalPageUpdate).
    final asyncPageData = ref.read(pageDataProvider(currentPage));
    asyncPageData.whenData((PageData pageData) {
      ref
          .read(memorizationSessionProvider.notifier)
          .handleTap(pageData: pageData);
    });
  }

  // Track if we're currently animating to prevent conflicts
  bool _isAnimating = false;
  int? _externalPageUpdate; // Track external page updates (from audio)

  // Navigate to a specific page (called from external sources like audio)
  void _navigateToPage(int pageNumber) {
    final targetIndex = pageNumber - 1;

    if (targetIndex < 0 || !_pageController.hasClients) {
      return;
    }

    // Navigate immediately without delay to ensure it happens as soon as audio starts
    if (mounted && _pageController.hasClients && !_isAnimating) {
      final currentIndex = _pageController.page?.round() ?? -1;
      if (currentIndex != targetIndex && targetIndex >= 0) {
        _isAnimating = true;
        _pageController
            .animateToPage(
              targetIndex,
              duration: AppDurations.medium,
              curve: Curves.easeInOut,
            )
            .then((_) {
              if (mounted) {
                _isAnimating = false;
                _externalPageUpdate = null; // Clear after animation
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
      }
    }
  }

  // Handle page changes from user swipes or external updates
  void _handlePageChanged(int index) {
    // Handle external updates (from audio) - don't update provider if already set
    // This prevents duplicate updates when navigating from external sources
    if (_isAnimating && _externalPageUpdate != null) {
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
    // Update the global state provider when user swipes to change pages.
    // This ensures the current page is always in sync with the PageView.
    ref.read(currentPageProvider.notifier).setPage(newPageNumber);
    _savePageToPrefs(newPageNumber);

    // Record reading progress (fire-and-forget, no await needed)
    // Add error handling to prevent silent failures in production
    ref
        .read(readingProgressServiceProvider.future)
        .then((service) => service.recordPageView(newPageNumber))
        .catchError((error, stackTrace) {
          // Log errors for debugging and monitoring
          // Silent failures would make statistics inaccurate
          if (kDebugMode) {
            debugPrint(
              'Failed to record page view for page $newPageNumber: $error',
            );
          }
          // TODO: Consider adding crash analytics reporting here
          // FirebaseCrashlytics.instance.recordError(error, stackTrace);
        });
  }

  // Build PageView with consistent configuration
  Widget _buildPageView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required bool isBetaMemorizing,
  }) {
    return PageView.builder(
      key: PageStorageKey('mushafPageView'),
      controller: _pageController,
      itemCount: itemCount,
      // Memory management for PageView:
      // - Flutter's PageView automatically keeps only a few pages in memory
      // - Font loading is managed by LRU cache (maxFontCacheSize = 50)
      // - Pages are automatically disposed when out of viewport
      physics: (enableMemorizationBeta && isBetaMemorizing)
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: _handlePageChanged,
      itemBuilder: itemBuilder,
    );
  }

  // Sync PageController position with provider if they don't match
  // WHY: Use PageControllerSyncMixin to reduce code duplication
  void _syncPageControllerIfNeeded(int currentPageNumber, int? totalPages) {
    if (!_pageController.hasClients) return;

    final controllerIndex = _pageController.page?.round() ?? -1;
    final controllerPage = controllerIndex + 1;

    if (controllerIndex >= 0 && controllerPage != currentPageNumber) {
      final targetIndex = currentPageNumber - 1;
      if (targetIndex >= 0 &&
          (totalPages == null || targetIndex < totalPages)) {
        // Use mixin method for consistent synchronization
        syncPageControllerToPage(
          _pageController,
          currentPageNumber,
          animated: false, // Instant navigation for MushafScreen
        );
      }
    }
  }

  // Handle external page updates (e.g., from audio config screen)
  void _handleExternalPageUpdate(int? previous, int next) {
    // Skip initial build
    if (previous == null) return;

    // Skip if no change
    if (previous == next) return;

    // Skip if already animating or disposed
    if (_isAnimating || !mounted) return;

    // If PageController not ready, mark for later
    if (!_pageController.hasClients) {
      _externalPageUpdate = next;
      return;
    }

    final currentIndex = _pageController.page?.round() ?? -1;
    final initialIndex = widget.initialPage - 1;
    final targetIndex = next - 1;

    // Skip if this is normal navigation (new screen created with initial page)
    if (next == widget.initialPage &&
        currentIndex == initialIndex &&
        previous == widget.initialPage) {
      return;
    }

    // Navigate if PageController is showing a different page than target
    // For same-page navigation, check if we're coming back from a temporary page
    final shouldNavigate =
        (currentIndex != targetIndex && targetIndex >= 0) ||
        (currentIndex == targetIndex && previous != next);

    if (shouldNavigate) {
      _externalPageUpdate = next;
      _navigateToPage(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the global page state
    final int currentPageNumber = ref.watch(currentPageProvider);

    // Listen to currentPageProvider changes for external updates (e.g., from audio)
    ref.listen(currentPageProvider, _handleExternalPageUpdate);

    // Listen for session transitions to reset circle values
    // WHY: Use ref.listenManual() to avoid unnecessary rebuilds
    // This listener only updates state when session actually changes
    ref.listenManual(memorizationSessionProvider, (prev, next) {
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
    // WHY: Use select() to only watch the pageNumber, reducing rebuilds
    // This ensures we only rebuild when the session's pageNumber changes,
    // not when other properties of the session change
    final memorizationSessionPageNumber = ref.watch(
      memorizationSessionProvider.select((session) => session?.pageNumber),
    );
    final bool isBetaMemorizing =
        enableMemorizationBeta &&
        memorizationSessionPageNumber != null &&
        memorizationSessionPageNumber == currentPageNumber;

    final asyncPageData = ref.watch(pageDataProvider(currentPageNumber));
    final totalPagesAsync = ref.watch(totalPagesProvider);

    // Cache totalPages value when available to use during loading states
    // This prevents the PageView from being removed from the tree during initial load
    totalPagesAsync.whenData((totalPages) {
      if (_lastKnownTotalPages != totalPages) {
        _lastKnownTotalPages = totalPages;
      }
    });

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
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title: extractString(
                      asyncPageData,
                      _generateTitleFromPageData,
                      defaultValue: '',
                    ),
                    titleOnRight:
                        true, // Title (juz/surah) on right, icons on left
                    onBookmarkPressed: () {
                      pushSlideTransition(
                        context,
                        const BookmarksScreen(),
                        direction: SlideDirection.fromRight,
                      );
                    },
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
                          ref
                              .read(memorizationIconFlashProvider.notifier)
                              .flash(times: 3);
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
                          ref
                              .read(memorizationIconFlashProvider.notifier)
                              .pulse();
                        }
                      },
                      child: totalPagesAsync.when(
                        data: (totalPages) {
                          // Sync PageController position with provider if needed
                          _syncPageControllerIfNeeded(
                            currentPageNumber,
                            totalPages,
                          );
                          // Use the total pages from the database for the current layout
                          return _buildPageView(
                            itemCount: totalPages,
                            itemBuilder: (context, index) {
                              // WHY: Use ValueKey for better widget reuse and performance
                              // This allows Flutter to efficiently reuse widgets when scrolling
                              return MushafPage(
                                key: ValueKey(index + 1),
                                pageNumber: index + 1,
                              );
                            },
                            isBetaMemorizing: isBetaMemorizing,
                          );
                        },
                        loading: () {
                          // Show PageView even when loading to preserve PageController position
                          // Use cached totalPages value to prevent PageController from resetting
                          if (_pageController.hasClients &&
                              _lastKnownTotalPages != null) {
                            // Use cached totalPages value to keep PageView in tree
                            // The PageView will be rebuilt with correct itemCount once totalPagesAsync resolves
                            return _buildPageView(
                              itemCount: _lastKnownTotalPages!,
                              itemBuilder: (context, index) {
                                // Show loading indicator for each page while totalPages is loading
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              isBetaMemorizing: isBetaMemorizing,
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        error: (error, stack) =>
                            Center(child: Text('Error loading pages: $error')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: MushafBottomNav(
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
                  // Only label the session that belongs to the displayed page.
                  if (session != null &&
                      session.pageNumber == currentPageNumber) {
                    centerLabel = computeMemorizationLabel(
                      pageData.layout,
                      session,
                    );
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
