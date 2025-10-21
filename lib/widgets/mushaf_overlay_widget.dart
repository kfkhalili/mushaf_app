import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../screens/mushaf_screen.dart'; // WHY: Import to get memorizationProvider

class MushafOverlayWidget extends ConsumerWidget {
  final bool isVisible;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onToggleMemorization; // WHY: Callback from parent

  const MushafOverlayWidget({
    super.key,
    required this.isVisible,
    required this.onBackButtonPressed,
    required this.onToggleMemorization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentTheme = ref.watch(themeProvider);
    // WHY: Watch the memorization state to update the button icon.
    final bool isMemorizing = ref
        .watch(memorizationProvider)
        .isMemorizationMode;

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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        // WHY: This is the new button for memorization mode.
                        IconButton(
                          icon: Icon(
                            isMemorizing ? Icons.school : Icons.school_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: onToggleMemorization,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: onBackButtonPressed,
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
