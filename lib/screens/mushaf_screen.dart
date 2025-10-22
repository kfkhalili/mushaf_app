import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
// import '../widgets/mushaf_overlay_widget.dart'; // WHY: Removed old overlay import
import '../widgets/mushaf_bottom_menu.dart'; // WHY: Added new bottom menu import
import '../providers.dart';
import '../models.dart';

// --- State Management for Memorization Mode ---
// (MemorizationState, MemorizationNotifier, memorizationProvider remain unchanged)
@immutable
class MemorizationState {
  final bool isMemorizationMode;
  final Map<int, int> revealedLinesMap; // Stores revealed *ayah* count per page

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
  // bool _isOverlayVisible = false; // WHY: Removed state for overlay visibility

  // void _toggleOverlay() { ... } // WHY: Removed function for toggling overlay

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

  // WHY: Renamed and simplified the tap handler for clarity.
  void _handleMemorizationTap() {
    final memorizationState = ref.read(memorizationProvider);

    // WHY: Only proceed if in memorization mode.
    if (!memorizationState.isMemorizationMode) {
      return; // Do nothing if not memorizing
    }

    final int currentPage =
        _pageController.page?.round() ?? (widget.initialPage - 1);
    final int pageNumber = currentPage + 1;

    final asyncPageData = ref.read(pageDataProvider(pageNumber));

    asyncPageData.whenData((PageData pageData) {
      // Find all unique ayahs on this page
      final Set<String> uniqueAyahs = <String>{};
      for (final line in pageData.layout.lines) {
        if (line.lineType == 'ayah') {
          for (final word in line.words) {
            if (word.ayahNumber > 0) {
              uniqueAyahs.add("${word.surahNumber}:${word.ayahNumber}");
            }
          }
        }
      }
      final int totalAyahsOnPage = uniqueAyahs.length;

      final int revealedCount =
          memorizationState.revealedLinesMap[pageNumber] ?? 0;

      // WHY: Only increment if the page is not yet fully revealed.
      if (revealedCount < totalAyahsOnPage) {
        ref.read(memorizationProvider.notifier).incrementReveal(pageNumber);
      }
      // WHY: No longer need to toggle overlay when page is complete.
    });
  }

  @override
  Widget build(BuildContext context) {
    // WHY: Wrap the content in a Scaffold to provide structure for the BottomAppBar.
    return Scaffold(
      // WHY: Use Scaffold's body for the main content (PageView).
      body: Stack(
        children: [
          // WHY: Wrap PageView in GestureDetector to capture taps for memorization.
          GestureDetector(
            onTap: _handleMemorizationTap,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: true,
              onPageChanged: (index) {
                _saveCurrentPage(index + 1);
                // WHY: No longer need to hide overlay on page change.
              },
              itemBuilder: (context, index) {
                return MushafPageWidget(pageNumber: index + 1);
              },
            ),
          ),
          // MushafOverlayWidget(...) // WHY: Removed the old overlay instance
        ],
      ),
      // WHY: Add the new persistent bottom menu.
      bottomNavigationBar: MushafBottomMenu(
        onBackButtonPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
