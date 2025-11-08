import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../constants.dart';
import 'bottom_nav_helpers.dart';

/// Audio playback controls widget for bottom navigation.
///
/// This widget displays play/pause, skip, and stop controls when audio
/// is active, or a play button when audio is not active.
///
/// Extracted from AppBottomNavigation to maintain DRY principles.
class AudioControls extends ConsumerWidget {
  final VoidCallback? onPlayPressed;

  const AudioControls({super.key, this.onPlayPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unselectedIconColor = BottomNavHelpers.getUnselectedIconColor(
      context,
    );
    final selectedIconColor = BottomNavHelpers.getSelectedIconColor(context);

    final audioState = ref.watch(audioStateProvider);
    // Show controls if we have any current playback state (playing or paused)
    final bool hasActivePlayback =
        audioState.currentSurahNumber != null &&
        audioState.currentAyahNumber != null;

    // If audio is playing or has active playback, show playback controls
    if (hasActivePlayback) {
      return SizedBox(
        height: kBottomNavBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stop button
            BottomNavHelpers.buildNavIconButton(
              context: context,
              icon: const Icon(Icons.stop),
              tooltip: 'إيقاف',
              onPressed: () async {
                await ref.read(audioStateProvider.notifier).stop();
              },
              color: unselectedIconColor,
            ),
            // Previous (skip backward) button
            BottomNavHelpers.buildNavIconButton(
              context: context,
              icon: const Icon(Icons.skip_previous),
              tooltip: 'السابق',
              onPressed: () async {
                await ref
                    .read(audioStateProvider.notifier)
                    .skipToPreviousAyah();
              },
              color: selectedIconColor,
            ),
            // Play/Pause button
            BottomNavHelpers.buildNavIconButton(
              context: context,
              icon: Icon(
                audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                size: kBottomNavIconSize,
              ),
              tooltip: audioState.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
              onPressed: () async {
                if (audioState.isPlaying) {
                  await ref.read(audioStateProvider.notifier).pause();
                } else {
                  await ref.read(audioStateProvider.notifier).resume();
                }
              },
              color: selectedIconColor,
            ),
            // Next (skip forward) button
            BottomNavHelpers.buildNavIconButton(
              context: context,
              icon: const Icon(Icons.skip_next),
              tooltip: 'التالي',
              onPressed: () async {
                await ref.read(audioStateProvider.notifier).skipToNextAyah();
              },
              color: selectedIconColor,
            ),
          ],
        ),
      );
    }

    // Show play button when not playing
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: BottomNavHelpers.buildNavIconButton(
        context: context,
        icon: const Icon(Icons.play_arrow, size: kBottomNavIconSize),
        tooltip: 'تشغيل',
        onPressed: onPlayPressed,
        color: unselectedIconColor,
      ),
    );
  }
}
