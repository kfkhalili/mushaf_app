import 'package:flutter/material.dart';
// Removed Riverpod dependency for beta-only widget

class CountdownCircle extends StatefulWidget {
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
  State<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends State<CountdownCircle>
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
    final theme = Theme.of(context);
    // WHY: Use the primary color for the background.
    final Color backgroundColor = theme.colorScheme.primary;
    // WHY: Use a contrasting color (like white or black based on theme) for text and border.
    final Color foregroundColor = theme.colorScheme.onPrimary;

    const double fontSize = 18.0; // Even smaller to comfortably fit 3-digit ranges

    // Determine which text to display. This is the core of the minimal change.
    final String textToShow = widget.centerLabel ?? '';

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
                    offset: const Offset(0, 4.0), // Fine-tuned centering
                    child: SizedBox(
                      width:
                          70.0, // Constrained area (FittedBox will scale down further if needed)
                      height: 70.0,
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
