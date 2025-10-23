import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/mushaf_screen.dart'; // For memorizationProvider

class CountdownCircle extends ConsumerWidget {
  const CountdownCircle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentCount = ref.watch(
      memorizationProvider.select((state) => state.currentRepetitions),
    );
    final theme = Theme.of(context);

    // WHY: Increased size for better visibility and overlap effect.
    const double circleDiameter = 56.0;
    const double fontSize = 20.0; // Adjusted font size

    return GestureDetector(
      onTap: () {
        ref.read(memorizationProvider.notifier).decrementRepetitions();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circleDiameter, // Use new size
            height: circleDiameter, // Use new size
            decoration: BoxDecoration(
              // WHY: Use a solid color (e.g., matching the bar) for better overlap appearance.
              color: const Color(0xFF212121),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2.0, // Slightly thicker border
              ),
              // Optional: Add a subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Text(
            currentCount.toString(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: fontSize, // Use adjusted font size
            ),
          ),
        ],
      ),
    );
  }
}
