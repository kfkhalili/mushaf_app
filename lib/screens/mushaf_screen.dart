import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
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

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  // WHY: This function saves the current page number to local storage.
  // It's called whenever the user finishes swiping to a new page.
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
    return GestureDetector(
      onTap: _toggleOverlay,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 604,
            reverse: true,
            // WHY: This callback fires every time the user settles on a new page.
            // We use it to save their progress.
            onPageChanged: (index) {
              // The PageView is 0-indexed, but our pages are 1-indexed.
              _saveCurrentPage(index + 1);
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
          ),
        ],
      ),
    );
  }
}
