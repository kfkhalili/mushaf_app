import 'package:flutter/material.dart';
import '../widgets/mushaf_page_widget.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
    ); // Start at page 1 (index 0)
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep PageView simple, responsible only for swiping
    return PageView.builder(
      controller: _pageController,
      itemCount: 604, // Standard number of pages
      itemBuilder: (context, index) {
        return MushafPageWidget(pageNumber: index + 1);
      },
    );
  }
}
