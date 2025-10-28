import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/mushaf_screen.dart'; // For memorizationProvider
import '../utils/helpers.dart';

class CountdownCircle extends ConsumerWidget {
  final VoidCallback? onTap;

  const CountdownCircle({super.key, this.onTap});

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

    const double circleDiameter = 64.0;
    const double fontSize = 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: foregroundColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Transform.translate(
            offset: const Offset(
              0,
              -2.0,
            ), // Nudge text up to compensate for font metrics
            child: Text(
              convertToEasternArabicNumerals(currentCount.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                fontFamily: 'quran-common', // Use a specific, reliable font
              ),
            ),
          ),
        ),
      ),
    );
  }
}
