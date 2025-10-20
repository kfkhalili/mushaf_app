import 'package:flutter/material.dart';

class MushafOverlayWidget extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onBackButtonPressed;

  const MushafOverlayWidget({
    super.key,
    required this.isVisible,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isVisible,
        // WHY: By wrapping the Container in an Align widget, we constrain it
        // to the top of the screen and allow it to shrink to the height of its contents.
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: const Color(0xFF212121), // A dark grey
            child: SafeArea(
              // Only apply vertical padding to avoid the notch, but let content go edge-to-edge.
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Right side: Back Arrow
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: onBackButtonPressed,
                    ),
                    // Left side: Bookmark and Options
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            /* Placeholder */
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            /* Placeholder */
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
