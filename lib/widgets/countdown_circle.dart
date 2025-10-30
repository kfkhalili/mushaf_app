import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/mushaf_screen.dart'; // For memorizationProvider
import '../utils/helpers.dart';

class CountdownCircle extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool showNumber;
  final String? centerLabel; // The only property added

  const CountdownCircle({
    super.key,
    this.onTap,
    this.showNumber = true,
    this.centerLabel,
  });

  @override
  ConsumerState<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends ConsumerState<CountdownCircle>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  Future<void> _handleTap() async {
    if (mounted) {
      setState(() => _scale = 0.92);
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) setState(() => _scale = 1.0);
    }
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final int currentCount = ref.watch(
      memorizationProvider.select((state) => state.currentRepetitions),
    );
    final theme = Theme.of(context);
    // WHY: Use the primary color for the background.
    final Color backgroundColor = theme.colorScheme.primary;
    // WHY: Use a contrasting color (like white or black based on theme) for text and border.
    final Color foregroundColor = theme.colorScheme.onPrimary;

    const double fontSize = 36.0; // Reduced base font size

    // Determine which text to display. This is the core of the minimal change.
    final String textToShow =
        widget.centerLabel ?? convertToEasternArabicNumerals(currentCount.toString());

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 80.0, // Reverted to original size
          height: 80.0, // Reverted to original size
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
            child: widget.centerLabel != null || widget.showNumber
                ? Transform.translate(
                    offset: const Offset(
                      0,
                      7.0,
                    ), // Nudge text down more to center it
                    child: SizedBox(
                      width:
                          70.0, // Larger constrained text area for better centering
                      height:
                          70.0, // Larger constrained text area for better centering
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: textToShow, // Use the determined text
                            style: TextStyle(
                              color: foregroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              fontFamily: 'quran-common',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Icon(Icons.check, color: foregroundColor, size: 36),
          ),
        ),
      ),
    );
  }
}
