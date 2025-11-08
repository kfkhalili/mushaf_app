import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../utils/ui_signals.dart';
import 'bottom_nav_helpers.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

/// Memorization toggle button widget for bottom navigation.
///
/// This widget displays a button to start/end memorization sessions
/// with animation support.
///
/// Extracted from AppBottomNavigation to maintain DRY principles.
class MemorizationButton extends ConsumerWidget {
  final int pageNumber;

  const MemorizationButton({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(memorizationSessionProvider);
    final unselectedIconColor = BottomNavHelpers.getUnselectedIconColor(
      context,
    );
    final selectedIconColor = BottomNavHelpers.getSelectedIconColor(context);

    // Listen to global flash tick to animate icon briefly
    final bool active = session != null && session.pageNumber == pageNumber;

    final String tooltip = enableMemorizationBeta
        ? (active ? 'End Memorization (Beta)' : 'Start Memorization (Beta)')
        : 'Memorization (Beta) disabled';
    final Color color = active ? selectedIconColor : unselectedIconColor;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        height: kBottomNavBarHeight,
        child: ValueListenableBuilder<int>(
          valueListenable: memorizationIconFlashTick,
          builder: (context, tick, child) {
            return TweenAnimationBuilder<double>(
              key: ValueKey(tick),
              tween: Tween(begin: 1.15, end: 1.0),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: child,
            );
          },
          child: BottomNavHelpers.buildNavIconButton(
            context: context,
            icon: Icon(
              active
                  ? FlutterIslamicIcons.solidQuran2
                  : FlutterIslamicIcons.quran2,
              size: kBottomNavIconSize,
            ),
            tooltip: tooltip,
            onPressed: () async {
              if (!enableMemorizationBeta) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memorization (Beta) is disabled'),
                  ),
                );
                return;
              }
              final notifier = ref.read(memorizationSessionProvider.notifier);
              if (active) {
                await notifier.endSession();
              } else {
                await notifier.startSession(
                  pageNumber: pageNumber,
                  firstAyahIndex: 0,
                );
              }
            },
            color: color,
          ),
        ),
      ),
    );
  }
}
