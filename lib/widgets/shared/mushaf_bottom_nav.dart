import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers.dart';
import '../../screens/audio_config_screen.dart';
import 'bottom_nav_helpers.dart';
import 'audio_controls.dart';
import 'memorization_button.dart';

/// Bottom navigation bar for MushafScreen.
///
/// Displays audio controls, memorization button, and back button.
///
/// Extracted from AppBottomNavigation to maintain separation of concerns
/// while sharing common patterns via BottomNavHelpers.
class MushafBottomNav extends ConsumerWidget {
  final int? currentPageNumber;
  final VoidCallback? onBackButtonPressed;

  const MushafBottomNav({
    super.key,
    this.currentPageNumber,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unselectedIconColor = BottomNavHelpers.getUnselectedIconColor(
      context,
    );
    final selectedIconColor = BottomNavHelpers.getSelectedIconColor(context);

    return BottomNavHelpers.buildBottomAppBar(
      context: context,
      child: IconTheme(
        data: IconThemeData(
          color: unselectedIconColor,
          size: kBottomNavIconSize,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Left Buttons: Audio controls or memorization + play
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show either playback controls OR play button + memorization
                _buildAudioControlsOrMemorization(
                  context,
                  ref,
                  selectedIconColor,
                  unselectedIconColor,
                ),
              ],
            ),
            // Right Button: Back button
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControlsOrMemorization(
    BuildContext context,
    WidgetRef ref,
    Color selectedIconColor,
    Color unselectedIconColor,
  ) {
    final audioState = ref.watch(audioStateProvider);
    final bool hasActivePlayback =
        audioState.currentSurahNumber != null &&
        audioState.currentAyahNumber != null;

    // If audio is active, show only audio controls
    if (hasActivePlayback) {
      return AudioControls();
    }

    // Show memorization button and play button when not playing
    final pageNumber = currentPageNumber ?? 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MemorizationButton(pageNumber: pageNumber),
        AudioControls(
          onPlayPressed: () {
            // Navigate to audio config screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AudioConfigScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return BottomNavHelpers.buildNavIconButton(
      context: context,
      icon: const Icon(Icons.arrow_forward_ios),
      tooltip: 'Back',
      onPressed: onBackButtonPressed,
      padding: const EdgeInsets.only(right: footerRightPadding),
    );
  }
}
