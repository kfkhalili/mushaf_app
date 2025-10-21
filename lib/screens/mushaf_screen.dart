import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mushaf_page_widget.dart';
import '../widgets/mushaf_overlay_widget.dart';

class MushafScreen extends StatefulWidget {
  final int initialPage;

  const MushafScreen({super.key, this.initialPage = 1});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late final PageController _pageController;
  bool _isOverlayVisible = false;
  bool _isMemorizationMode = false;

  // This map stores the reveal progress for each page individually.
  final Map<int, int> _memorizationProgress = {};

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  void _toggleMemorizationMode() {
    setState(() {
      _isMemorizationMode = !_isMemorizationMode;
      _isOverlayVisible = false; // Hide overlay on mode switch
    });
  }

  // This is the tap handler passed to the memorization view.
  void _handleMemorizationTap(int pageNumber, int totalAyahsOnPage) {
    setState(() {
      int currentIndex = _memorizationProgress[pageNumber] ?? 0;
      if (currentIndex < totalAyahsOnPage - 1) {
        // If not fully revealed, reveal next ayah
        _memorizationProgress[pageNumber] = currentIndex + 1;
      } else {
        // If fully revealed, a tap now toggles the overlay. This is the "escape hatch".
        _toggleOverlay();
      }
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

  @override
  Widget build(BuildContext context) {
    // The GestureDetector now only wraps the PageView. It's only active for reading mode.
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Only toggle the overlay if NOT in memorization mode.
            // The memorization view will handle its own taps.
            if (!_isMemorizationMode) {
              _toggleOverlay();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: 604,
            reverse: true,
            onPageChanged: (index) {
              final pageNumber = index + 1;
              _saveCurrentPage(pageNumber);
              // Reset memorization progress when swiping to a new page for a fresh start.
              setState(() {
                _memorizationProgress[pageNumber] = 0;
              });
            },
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return MushafPageWidget(
                pageNumber: pageNumber,
                isMemorizationMode: _isMemorizationMode,
                // Pass the current progress for this page.
                memorizationAyahIndex: _memorizationProgress[pageNumber] ?? 0,
                // Pass the tap handler down to the memorization view.
                onAyahReveal: (totalAyahs) =>
                    _handleMemorizationTap(pageNumber, totalAyahs),
              );
            },
          ),
        ),
        // The overlay is a sibling in the Stack, ensuring it's always on top.
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
    );
  }
}
