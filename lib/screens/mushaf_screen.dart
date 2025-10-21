import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_overlay_widget.dart';
import '../providers.dart'; // We need this for pageDataProvider
import '../models.dart'; // We need this for PageData

// --- State Management for Memorization Mode ---

@immutable
class MemorizationState {
  final bool isMemorizationMode;
  // WHY: Maps pageNumber to the number of *ayahs* revealed for that page.
  final Map<int, int> revealedLinesMap;

  const MemorizationState({
    this.isMemorizationMode = false,
    this.revealedLinesMap = const {},
  });

  MemorizationState copyWith({
    bool? isMemorizationMode,
    Map<int, int>? revealedLinesMap,
  }) {
    return MemorizationState(
      isMemorizationMode: isMemorizationMode ?? this.isMemorizationMode,
      revealedLinesMap: revealedLinesMap ?? this.revealedLinesMap,
    );
  }
}

class MemorizationNotifier extends StateNotifier<MemorizationState> {
  MemorizationNotifier() : super(const MemorizationState());

  void toggleMode() {
    final bool wasMemorizing = state.isMemorizationMode;
    state = state.copyWith(
      isMemorizationMode: !wasMemorizing,
      // WHY: We reset the reveal counters when toggling mode
      // to ensure a fresh start next time.
      revealedLinesMap: const {},
    );
  }

  void incrementReveal(int pageNumber) {
    final int currentCount = state.revealedLinesMap[pageNumber] ?? 0;
    final newMap = Map<int, int>.from(state.revealedLinesMap);
    newMap[pageNumber] = currentCount + 1;
    state = state.copyWith(revealedLinesMap: newMap);
  }
}

final memorizationProvider =
    StateNotifierProvider<MemorizationNotifier, MemorizationState>(
      (ref) => MemorizationNotifier(),
    );

// --- Mushaf Screen Widget ---

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const MushafScreen({super.key, this.initialPage = 1});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late final PageController _pageController;
  bool _isOverlayVisible = false;

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  Future<void> _saveCurrentPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', pageNumber);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final memorizationState = ref.read(memorizationProvider);
    final int currentPage =
        _pageController.page?.round() ?? (widget.initialPage - 1);
    final int pageNumber = currentPage + 1;

    if (!memorizationState.isMemorizationMode) {
      // WHY: Default behavior when not in memorization mode.
      _toggleOverlay();
      return;
    }

    // WHY: When in memorization mode, taps reveal ayahs.
    // We must read the page data to know when the page is complete.
    final asyncPageData = ref.read(pageDataProvider(pageNumber));

    asyncPageData.whenData((PageData pageData) {
      // WHY: Find all unique ayahs on this page to get the total count.
      final Set<String> uniqueAyahs = <String>{};
      for (final line in pageData.layout.lines) {
        if (line.lineType == 'ayah') {
          for (final word in line.words) {
            // We only care about ayahs > 0 (not basmallahs marked as ayah 0)
            if (word.ayahNumber > 0) {
              uniqueAyahs.add("${word.surahNumber}:${word.ayahNumber}");
            }
          }
        }
      }
      final int totalAyahsOnPage = uniqueAyahs.length;

      final int revealedCount =
          memorizationState.revealedLinesMap[pageNumber] ?? 0;

      if (revealedCount < totalAyahsOnPage) {
        // WHY: If page is not complete, increment the reveal count.
        ref.read(memorizationProvider.notifier).incrementReveal(pageNumber);
      } else {
        // WHY: If page is complete, allow the overlay to be toggled.
        _toggleOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // WHY: We watch the provider to rebuild when memorization mode is toggled.
    final bool isMemorizing = ref
        .watch(memorizationProvider)
        .isMemorizationMode;

    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            reverse: true,
            onPageChanged: (index) {
              final int newPageNumber = index + 1;
              _saveCurrentPage(newPageNumber);

              // WHY: If the user swipes to a new page while memorizing,
              // we must hide the overlay to force them to reveal the new page.
              if (isMemorizing && _isOverlayVisible) {
                setState(() {
                  _isOverlayVisible = false;
                });
              }
            },
            itemBuilder: (context, index) {
              return MushafPageWidget(pageNumber: index + 1);
            },
          ),
          MushafOverlayWidget(
            isVisible: _isOverlayVisible,
            onBackButtonPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            // WHY: We pass a callback to let the overlay toggle the
            // memorization mode and hide itself.
            onToggleMemorization: () {
              ref.read(memorizationProvider.notifier).toggleMode();
              if (_isOverlayVisible) {
                _toggleOverlay();
              }
            },
          ),
        ],
      ),
    );
  }
}
