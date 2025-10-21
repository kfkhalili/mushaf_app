import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class MushafOverlayWidget extends ConsumerWidget {
  final bool isVisible;
  final VoidCallback onBackButtonPressed;

  const MushafOverlayWidget({
    super.key,
    required this.isVisible,
    required this.onBackButtonPressed,
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
                    // WHY: The first child in the Row is on the LEFT. This is the
                    // correct place for the options and bookmark icons.
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
                      ],
                    ),
                    // WHY: The last child in the Row is on the RIGHT. This is the
                    // correct place for the back arrow.
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
