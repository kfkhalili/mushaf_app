import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mushaf_bottom_menu.dart';
import 'countdown_circle.dart';
import '../screens/mushaf_screen.dart'; // For memorizationProvider

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
    final isMemorizing = ref.watch(
      memorizationProvider.select((s) => s.isMemorizationMode),
    );
    // Constants should match those used in the child widgets
    const double barHeight = 48.0;
    const double circleDiameter = 56.0;

    // WHY: Use a Stack here to layer the circle over the BottomAppBar.
    // The Stack needs enough height to contain both the bar and the overlapping circle part.
    // We add half the circle's diameter to the bar height for the total stack height.
    return SizedBox(
      height: barHeight + (circleDiameter / 2), // Total height needed
      child: Stack(
        // Allow circle to overflow visually
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter, // Align BottomAppBar to bottom
        children: [
          // The actual BottomAppBar sits at the bottom of the Stack
          MushafBottomMenu(
            currentPageNumber: currentPageNumber,
            onBackButtonPressed: onBackButtonPressed,
          ),

          // The overlapping CountdownCircle, positioned relative to the Stack
          if (isMemorizing)
            Positioned(
              // WHY: Position the *bottom* of the circle 'barHeight' pixels
              // from the bottom of the Stack container. This aligns the
              // circle's center exactly with the top edge of the BottomAppBar.
              bottom: barHeight - (circleDiameter / 2),
              // Horizontal centering relative to the Stack
              left: 0,
              right: 0,
              child: const CountdownCircle(),
            ),
        ],
      ),
    );
  }
}
