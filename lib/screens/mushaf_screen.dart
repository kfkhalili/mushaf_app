import 'package:flutter/material.dart';
import '../widgets/mushaf_page_widget.dart';

class MushafScreen extends StatefulWidget {
  // Add initialPage parameter
  final int initialPage;

  const MushafScreen({super.key, this.initialPage = 1});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Use the passed initialPage (subtract 1 for 0-based index)
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 604,
      // WHY: This reverses the page order and swipe direction.
      // Now, a right-swipe will advance to the next page (e.g., from page 2 to 3),
      // which is the natural behavior for reading a Mushaf.
      reverse: true,
      itemBuilder: (context, index) {
        return MushafPageWidget(pageNumber: index + 1);
      },
    );
  }
}
