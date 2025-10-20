import 'package:flutter/material.dart';
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
  bool _isOverlayVisible = false; // State is now managed here

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
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
    // The GestureDetector wraps the whole Stack
    return GestureDetector(
      onTap: _toggleOverlay,
      child: Stack(
        children: [
          // --- Layer 1: The Page Viewer ---
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            reverse: true,
            itemBuilder: (context, index) {
              // The page widget is now simple and stateless
              return MushafPageWidget(pageNumber: index + 1);
            },
          ),
          // --- Layer 2: The Overlay ---
          MushafOverlayWidget(
            isVisible: _isOverlayVisible,
            onBackButtonPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
