import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_overlay_widget.dart';
import '../providers.dart';

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const MushafScreen({super.key, this.initialPage = 1});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late final PageController _pageController;
  bool _isOverlayVisible = false;
  bool _isMemorizationMode = false;

  // All state variables are now correctly defined here.
  final Map<int, int> _memorizationProgress = {};
  Map<String, List<int>> _currentPageAyahWordMap = {};
  List<String> _ayahKeysForCurrentPage = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _prepareMemorizationDataForPage(widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // The tap handler for the entire screen.
  void _handleTap() {
    setState(() {
      if (_isMemorizationMode) {
        _revealNextAyah();
      } else {
        _isOverlayVisible = !_isOverlayVisible;
      }
    });
  }

  // This method is now correctly defined.
  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  Future<void> _toggleMemorizationMode() async {
    setState(() {
      _isMemorizationMode = !_isMemorizationMode;
      _isOverlayVisible = false;
    });

    if (_isMemorizationMode) {
      await _startMemorizationForCurrentPage();
    }
  }

  Future<void> _startMemorizationForCurrentPage() async {
    final currentPage =
        _pageController.page?.round() ?? (widget.initialPage - 1);
    final pageNumber = currentPage + 1;

    final ayahWordMap = await ref.read(ayahWordMapProvider(pageNumber).future);

    setState(() {
      _currentPageAyahWordMap = ayahWordMap;
      _ayahKeysForCurrentPage = ayahWordMap.keys.toList();
      _memorizationProgress[pageNumber] = 0; // Reset progress for the page
      // Recalculate visible words
    });
  }

  void _revealNextAyah() {
    final int currentPage =
        _pageController.page?.round() ?? (widget.initialPage - 1);
    final int pageNumber = currentPage + 1;
    final int currentProgress = _memorizationProgress[pageNumber] ?? 0;

    if (currentProgress < _ayahKeysForCurrentPage.length - 1) {
      setState(() {
        _memorizationProgress[pageNumber] = currentProgress + 1;
      });
    } else {
      _toggleOverlay();
    }
  }

  Future<void> _prepareMemorizationDataForPage(int pageNumber) async {
    final ayahWordMap = await ref.read(ayahWordMapProvider(pageNumber).future);
    if (mounted) {
      setState(() {
        _currentPageAyahWordMap = ayahWordMap;
        _ayahKeysForCurrentPage = ayahWordMap.keys.toList();
      });
    }
  }

  Future<void> _saveCurrentPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            reverse: true,
            onPageChanged: (index) {
              final pageNumber = index + 1;
              _saveCurrentPage(pageNumber);
              _prepareMemorizationDataForPage(pageNumber);
              setState(() {
                _memorizationProgress[pageNumber] = 0;
              });
            },
            itemBuilder: (context, index) {
              return MushafPageWidget(
                pageNumber: index + 1,
                isMemorizationMode: _isMemorizationMode,
                visibleWordIds: _getVisibleWordIdsForPage(index + 1),
              );
            },
          ),
          MushafOverlayWidget(
            isVisible: _isOverlayVisible,
            onBackButtonPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            onMemorizationModePressed: _toggleMemorizationMode,
          ),
        ],
      ),
    );
  }

  Set<int> _getVisibleWordIdsForPage(int pageNumber) {
    if (!_isMemorizationMode) {
      return {};
    }

    final Set<int> visibleIds = {};
    final int currentProgress = _memorizationProgress[pageNumber] ?? 0;

    for (
      int i = 0;
      i <= currentProgress && i < _ayahKeysForCurrentPage.length;
      i++
    ) {
      final ayahKey = _ayahKeysForCurrentPage[i];
      visibleIds.addAll(_currentPageAyahWordMap[ayahKey] ?? []);
    }

    if (currentProgress < _ayahKeysForCurrentPage.length - 1) {
      final nextAyahKey = _ayahKeysForCurrentPage[currentProgress + 1];
      final nextAyahWords = _currentPageAyahWordMap[nextAyahKey];
      if (nextAyahWords != null && nextAyahWords.isNotEmpty) {
        visibleIds.add(nextAyahWords.first);
      }
    }

    return visibleIds;
  }
}
