import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_bottom_menu.dart';
import '../providers.dart';
import '../models.dart';

// --- State Management for Memorization Mode ---
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

  // WHY: Accept currentPageNumber to initialize the first reveal.
  void toggleMode({int? currentPageNumber}) {
    final bool enabling = !state.isMemorizationMode;
    Map<int, int> newMap = const {}; // Reset map when toggling off

    // WHY: If enabling memorization mode and a page number is provided,
    // initialize the reveal count for that page to 1.
    if (enabling && currentPageNumber != null) {
      newMap = {currentPageNumber: 1};
    }

    state = state.copyWith(
      isMemorizationMode: enabling,
      revealedLinesMap: newMap, // Use the potentially initialized map
    );
  }

  void incrementReveal(int pageNumber) {
    final int currentCount = state.revealedLinesMap[pageNumber] ?? 0;
    // WHY: Ensure map is mutable before updating
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
  // Store current page number locally to pass to toggleMode
  late int _currentPageNumber;

  Future<void> _saveCurrentPage(int pageNumber) async {
    // Update local state when page changes
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
    _currentPageNumber = widget.initialPage; // Initialize current page
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleMemorizationTap() {
    final memorizationState = ref.read(memorizationProvider);
    if (!memorizationState.isMemorizationMode) {
      return;
    }

    // Use the local _currentPageNumber state variable
    final int pageNumber = _currentPageNumber;
    final asyncPageData = ref.read(pageDataProvider(pageNumber));

    asyncPageData.whenData((PageData pageData) {
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

      if (revealedCount < totalAyahsOnPage) {
        ref.read(memorizationProvider.notifier).incrementReveal(pageNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _handleMemorizationTap,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: true,
              onPageChanged: (index) {
                // Save and update local state
                _saveCurrentPage(index + 1);
              },
              itemBuilder: (context, index) {
                return MushafPageWidget(pageNumber: index + 1);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MushafBottomMenu(
        // Pass the current page number to the menu
        currentPageNumber: _currentPageNumber,
        onBackButtonPressed: () async {
          if (Navigator.canPop(context)) {
            await _clearLastPage();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
