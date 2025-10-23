import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_bottom_menu.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart'; // Import constants for initialWordCount
import 'dart:collection'; // Needed for SplayTreeMap in _handleMemorizationTap

// --- State Management for Memorization Mode ---
// Placed here because the state affects both the MushafPageWidget (visibility)
// and the MushafBottomMenu (icon/circle display). The screen coordinates this.
@immutable
class MemorizationState {
  final bool isMemorizationMode;
  // State stores the index of the LAST fully revealed ayah. -1 = initial N words state.
  final Map<int, int> lastRevealedAyahIndexMap;
  final int repetitionGoal;
  final int currentRepetitions;

  const MemorizationState({
    this.isMemorizationMode = false,
    this.lastRevealedAyahIndexMap = const {},
    this.repetitionGoal = 5, // Default goal
    this.currentRepetitions = 0, // Initial count
  });

  MemorizationState copyWith({
    bool? isMemorizationMode,
    Map<int, int>? lastRevealedAyahIndexMap,
    int? repetitionGoal,
    int? currentRepetitions,
  }) {
    return MemorizationState(
      isMemorizationMode: isMemorizationMode ?? this.isMemorizationMode,
      lastRevealedAyahIndexMap:
          lastRevealedAyahIndexMap ?? this.lastRevealedAyahIndexMap,
      repetitionGoal: repetitionGoal ?? this.repetitionGoal,
      currentRepetitions: currentRepetitions ?? this.currentRepetitions,
    );
  }
}

class MemorizationNotifier extends StateNotifier<MemorizationState> {
  MemorizationNotifier() : super(const MemorizationState());

  void toggleMode({int? currentPageNumber}) {
    final bool enabling = !state.isMemorizationMode;
    Map<int, int> newMap = const {}; // Reset map when toggling off

    // If enabling, set the index for the current page to -1 (initial state).
    if (enabling && currentPageNumber != null) {
      newMap = {currentPageNumber: -1};
      // Reset counter to goal when enabling
      state = state.copyWith(currentRepetitions: state.repetitionGoal);
    } else {
      // Reset counter when disabling
      state = state.copyWith(currentRepetitions: 0);
    }

    state = state.copyWith(
      isMemorizationMode: enabling,
      lastRevealedAyahIndexMap: newMap, // Use the potentially initialized map
    );
  }

  void disableMode() {
    if (state.isMemorizationMode) {
      state = state.copyWith(
        isMemorizationMode: false,
        lastRevealedAyahIndexMap: const {}, // Reset map
        currentRepetitions: 0, // Reset counter
      );
    }
  }

  void decrementRepetitions() {
    if (state.currentRepetitions > 0) {
      state = state.copyWith(currentRepetitions: state.currentRepetitions - 1);
    }
    // Optional: If count reaches 0, automatically advance? Or just stop?
    // Current logic just stops at 0.
  }

  void setRepetitionGoal(int goal) {
    if (goal > 0) {
      state = state.copyWith(repetitionGoal: goal);
      if (state.isMemorizationMode) {
        state = state.copyWith(currentRepetitions: goal);
      }
    }
  }

  // Updates the index based on the logic described (first tap vs subsequent).
  void revealNextStep(
    int pageNumber,
    List<Word> allWords,
    List<String> orderedKeys,
  ) {
    final int currentIndex = state.lastRevealedAyahIndexMap[pageNumber] ?? -1;
    int nextIndex = currentIndex; // Default to current

    if (currentIndex == -1) {
      // First tap after initial reveal
      // Ensure there are enough words to determine the index
      if (allWords.isNotEmpty && initialWordCount > 0) {
        // Clamp word index to prevent out of bounds
        int wordIndex = (initialWordCount - 1).clamp(0, allWords.length - 1);
        Word lastWordInitiallyShown = allWords[wordIndex];
        String lastAyahKey =
            "${lastWordInitiallyShown.surahNumber.toString().padLeft(3, '0')}:${lastWordInitiallyShown.ayahNumber.toString().padLeft(3, '0')}";
        nextIndex = orderedKeys.indexOf(
          lastAyahKey,
        ); // Find index of the ayah containing the last initial word
      } else {
        // Edge case: No words or initialWordCount is 0
        nextIndex = 0; // Move to reveal the first ayah
      }
      // Ensure index is valid, default to 0 if something went wrong
      if (nextIndex < 0) nextIndex = 0;
    } else if (currentIndex < orderedKeys.length - 1) {
      // Subsequent taps
      nextIndex = currentIndex + 1;
    } else {
      // Already fully revealed or beyond, do nothing
      return;
    }

    final newMap = Map<int, int>.from(state.lastRevealedAyahIndexMap);
    newMap[pageNumber] = nextIndex;
    // Reset repetition count whenever the revealed ayah index changes
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

// --- Mushaf Screen Widget ---

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const MushafScreen({super.key, this.initialPage = 1});
  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late final PageController _pageController;
  late int _currentPageNumber;

  Future<void> _saveCurrentPage(int pageNumber) async {
    setState(() {
      _currentPageNumber = pageNumber;
    });
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
    _currentPageNumber = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Tap handler calls the revealNextStep logic in the notifier.
  void _handleMemorizationTap() {
    final memorizationNotifier = ref.read(memorizationProvider.notifier);
    final memorizationState = ref.read(memorizationProvider);

    if (!memorizationState.isMemorizationMode) {
      return;
    }

    final int pageNumber = _currentPageNumber;
    // Use read as we don't need rebuilds here based on pageData
    final asyncPageData = ref.read(pageDataProvider(pageNumber));

    asyncPageData.whenData((PageData pageData) {
      // --- Gather necessary data for revealNextStep ---
      final ayahsOnPageMap = SplayTreeMap<String, List<Word>>();
      final List<Word> allQuranWordsOnPage = [];
      for (final line in pageData.layout.lines) {
        if (line.lineType == 'ayah') {
          for (final word in line.words) {
            if (word.ayahNumber > 0) {
              allQuranWordsOnPage.add(word);
              final String key =
                  "${word.surahNumber.toString().padLeft(3, '0')}:${word.ayahNumber.toString().padLeft(3, '0')}";
              ayahsOnPageMap.putIfAbsent(key, () => []).add(word);
            }
          }
        }
      }
      final List<String> orderedAyahKeys = ayahsOnPageMap.keys.toList();
      // --- End data gathering ---

      // Check if page is already fully revealed before calling notifier
      final int currentIndex =
          memorizationState.lastRevealedAyahIndexMap[pageNumber] ?? -1;
      // Page is fully revealed if the last revealed index is the index of the last ayah
      if (currentIndex >= orderedAyahKeys.length - 1) {
        return; // Already showing the last ayah fully
      }

      // Call the notifier method to update the state
      memorizationNotifier.revealNextStep(
        pageNumber,
        allQuranWordsOnPage,
        orderedAyahKeys,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch state ONLY needed for the back button logic here
    final isMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );

    return Scaffold(
      // Body is simple GestureDetector + PageView
      body: GestureDetector(
        onTap: _handleMemorizationTap,
        child: PageView.builder(
          controller: _pageController,
          itemCount: 604,
          reverse: true,
          onPageChanged: (index) {
            _saveCurrentPage(index + 1);
          },
          itemBuilder: (context, index) {
            return MushafPageWidget(pageNumber: index + 1);
          },
        ),
      ),
      bottomNavigationBar: MushafBottomMenu(
        currentPageNumber: _currentPageNumber,
        onBackButtonPressed: () async {
          final memorizationNotifier = ref.read(memorizationProvider.notifier);
          // Use the watched 'isMemorizing' variable directly
          if (Navigator.canPop(context)) {
            await _clearLastPage();
            if (isMemorizing) {
              // Use watched variable
              memorizationNotifier.disableMode();
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
