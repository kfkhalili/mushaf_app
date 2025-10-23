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
    // WHY: Use the primary color for the background.
    final Color backgroundColor = theme.colorScheme.primary;
    // WHY: Use a contrasting color (like white or black based on theme) for text and border.
    final Color foregroundColor = theme.colorScheme.onPrimary;

    const double circleDiameter = 56.0;
    const double fontSize = 20.0;

    return GestureDetector(
      onTap: () {
        ref.read(memorizationProvider.notifier).decrementRepetitions();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: BoxDecoration(
              // WHY: Solid primary color background.
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                // WHY: Contrasting border color.
                color: foregroundColor,
                width: 2.0,
              ),
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
              // WHY: Contrasting text color.
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
