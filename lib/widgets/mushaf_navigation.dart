import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mushaf_bottom_menu.dart';
// import 'countdown_circle.dart'; // No longer needed here
// import '../screens/mushaf_screen.dart'; // No longer needed here

// WHY: This widget now simply acts as a container or wrapper for the bottom menu,
// passing necessary parameters down. The overlap logic is handled in MushafScreen.
class MushafNavigation extends ConsumerWidget {
  final VoidCallback onBackButtonPressed;
  final int currentPageNumber;

  const MushafNavigation({
    super.key,
    required this.onBackButtonPressed,
    required this.currentPageNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: Directly return the MushafBottomMenu. The Stack is in MushafScreen.
    return MushafBottomMenu(
      currentPageNumber: currentPageNumber,
      onBackButtonPressed: onBackButtonPressed,
    );
  }
}
