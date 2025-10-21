import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class MushafOverlayWidget extends ConsumerWidget {
  final bool isVisible;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onMemorizationModePressed; // New callback

  const MushafOverlayWidget({
    super.key,
    required this.isVisible,
    required this.onBackButtonPressed,
    required this.onMemorizationModePressed, // New callback
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentTheme = ref.watch(themeProvider);

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: const Color(0xFF212121),
            child: SafeArea(
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
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: onBackButtonPressed,
                    ),
                    // Left side: Options
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- NEW ICON BUTTON ---
                        IconButton(
                          icon: const Icon(
                            Icons
                                .style, // An icon that suggests different views/modes
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: onMemorizationModePressed,
                        ),
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
                        PopupMenuButton<AppThemeMode>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 28,
                          ),
                          onSelected: (AppThemeMode mode) {
                            ref.read(themeProvider.notifier).setTheme(mode);
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<AppThemeMode>>[
                                CheckedPopupMenuItem<AppThemeMode>(
                                  value: AppThemeMode.light,
                                  checked: currentTheme == AppThemeMode.light,
                                  child: const Text('Light'),
                                ),
                                CheckedPopupMenuItem<AppThemeMode>(
                                  value: AppThemeMode.dark,
                                  checked: currentTheme == AppThemeMode.dark,
                                  child: const Text('Dark'),
                                ),
                                CheckedPopupMenuItem<AppThemeMode>(
                                  value: AppThemeMode.sepia,
                                  checked: currentTheme == AppThemeMode.sepia,
                                  child: const Text('Sepia'),
                                ),
                                const PopupMenuDivider(),
                                CheckedPopupMenuItem<AppThemeMode>(
                                  value: AppThemeMode.system,
                                  checked: currentTheme == AppThemeMode.system,
                                  child: const Text('Auto (System)'),
                                ),
                              ],
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
