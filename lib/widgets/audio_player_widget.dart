import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models.dart';
import '../utils/helpers.dart';

/// Floating audio player widget that appears when audio is playing.
class AudioPlayerWidget extends ConsumerStatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<dynamic>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    // Set up listeners when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  void _setupListeners() async {
    try {
      final audioService = await ref.read(audioServiceProvider.future);

      // Cancel existing subscriptions
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _playerStateSubscription?.cancel();

      // Listen to position and state updates to trigger widget rebuilds
      _positionSubscription = audioService.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      _durationSubscription = audioService.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _currentDuration = duration;
          });
        }
      });

      _playerStateSubscription = audioService.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isCurrentlyPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      // Ignore errors in listener setup
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getAyahLabel(AudioState audioState) {
    if (audioState.currentSurahNumber == null ||
        audioState.currentAyahNumber == null) {
      return '';
    }

    final surahNum = convertToEasternArabicNumerals(
      audioState.currentSurahNumber.toString(),
    );
    final ayahNum = convertToEasternArabicNumerals(
      audioState.currentAyahNumber.toString(),
    );
    return 'سورة $surahNum، آية $ayahNum';
  }

  Duration? _currentPosition;
  Duration? _currentDuration;
  bool _isCurrentlyPlaying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioStateProvider);

    // Update local state from audio service
    ref.read(audioServiceProvider.future).then((audioService) {
      _currentPosition = audioService.position;
      _currentDuration = audioService.duration;
      _isCurrentlyPlaying = audioService.isPlaying;
    });

    // Only show if audio is playing or has been played
    if (!audioState.isPlaying &&
        audioState.currentSurahNumber == null &&
        audioState.currentAyahNumber == null) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.cardColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            // Play/Pause button
            IconButton(
              icon: Icon(
                (_isCurrentlyPlaying || audioState.isPlaying)
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              onPressed: () async {
                if (_isCurrentlyPlaying || audioState.isPlaying) {
                  await ref.read(audioStateProvider.notifier).pause();
                } else {
                  await ref.read(audioStateProvider.notifier).resume();
                }
              },
            ),
            const SizedBox(width: 8),
            // Ayah label and time
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  _getAyahLabel(audioState),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '${_formatDuration(_currentPosition ?? audioState.position)} / ${_formatDuration(_currentDuration ?? audioState.duration)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Stop button
            IconButton(
              icon: Icon(
                Icons.stop_circle,
                size: 24,
                color: theme.colorScheme.error,
              ),
              onPressed: () async {
                await ref.read(audioStateProvider.notifier).stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
