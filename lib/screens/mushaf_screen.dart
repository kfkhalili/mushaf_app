import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_navigation.dart'; // Import the container widget
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import 'dart:collection';

// --- State Management for Memorization Mode ---
// (MemorizationState and Notifier remain the same)
@immutable
class MemorizationState {
  final bool isMemorizationMode;
  final Map<int, int> lastRevealedAyahIndexMap;
  final int repetitionGoal;
  final int currentRepetitions;
  const MemorizationState({
    this.isMemorizationMode = false,
    this.lastRevealedAyahIndexMap = const {},
    this.repetitionGoal = 5,
    this.currentRepetitions = 0,
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
    );
  }

  void disableMode() {
    if (state.isMemorizationMode) {
      state = state.copyWith(
        isMemorizationMode: false,
        lastRevealedAyahIndexMap: const {},
        currentRepetitions: 0,
      );
    }
  }

  void decrementRepetitions() {
    if (state.currentRepetitions > 0) {
      state = state.copyWith(currentRepetitions: state.currentRepetitions - 1);
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
    final int currentIndex = state.lastRevealedAyahIndexMap[pageNumber] ?? -1;
    int nextIndex = currentIndex;
    if (currentIndex == -1) {
      if (allWords.isNotEmpty && initialWordCount > 0) {
        int wordIndex = (initialWordCount - 1).clamp(0, allWords.length - 1);
        Word lastWordInitiallyShown = allWords[wordIndex];
        String lastAyahKey =
            "${lastWordInitiallyShown.surahNumber.toString().padLeft(3, '0')}:${lastWordInitiallyShown.ayahNumber.toString().padLeft(3, '0')}";
        nextIndex = orderedKeys.indexOf(lastAyahKey);
      } else {
        nextIndex = 0;
      }
      if (nextIndex < 0) nextIndex = 0;
    } else if (currentIndex < orderedKeys.length - 1) {
      nextIndex = currentIndex + 1;
    } else {
      return;
    }
    final newMap = Map<int, int>.from(state.lastRevealedAyahIndexMap);
    newMap[pageNumber] = nextIndex;
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
      final int currentIndex =
          memorizationState.lastRevealedAyahIndexMap[pageNumber] ?? -1;
      if (currentIndex >= orderedAyahKeys.length - 1) {
        return;
      } // Already fully revealed
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

    // Read state needed ONLY for the back button logic here
    final isMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: _handleMemorizationTap,
        child: PageView.builder(
          controller: _pageController,
          // WHY: Use the named constant for total page count.
          itemCount: totalPages,
          reverse: true,
          onPageChanged: (index) {
            final int newPageNumber = index + 1;
            // WHY: Update the global state provider.
            ref.read(currentPageProvider.notifier).setPage(newPageNumber);
            _savePageToPrefs(newPageNumber);
          },
          itemBuilder: (context, index) {
            return MushafPageWidget(pageNumber: index + 1);
          },
        ),
      ),
      bottomNavigationBar: MushafNavigation(
        // WHY: Pass the page number from the watched provider.
        currentPageNumber: currentPageNumber,
        onBackButtonPressed: () async {
          final memorizationNotifier = ref.read(memorizationProvider.notifier);
          if (Navigator.canPop(context)) {
            await _clearLastPage();
            if (isMemorizing) {
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
