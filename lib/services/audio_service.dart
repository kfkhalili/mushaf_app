import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models.dart';
import 'database_service.dart';

/// Service for managing audio playback of Quranic recitation.
/// Handles both full surah playback and verse-by-verse playback.
class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseService _databaseService;

  // Current playback state
  SurahAudio? _currentSurahAudio;
  AyahSegment? _currentAyahSegment;
  // Note: isPlaying now uses _audioPlayer.playing directly, no need for _isPlaying flag
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioService(this._databaseService);

  // Getters
  AudioPlayer get player => _audioPlayer;
  bool get isPlaying => _audioPlayer.playing;
  SurahAudio? get currentSurahAudio => _currentSurahAudio;
  AyahSegment? get currentAyahSegment => _currentAyahSegment;

  /// Stream of current playback position
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Stream of buffered position
  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;

  /// Stream of total duration
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Stream of player state
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Get current position
  Duration? get position => _audioPlayer.position;

  /// Get total duration
  Duration? get duration => _audioPlayer.duration;

  /// Get player state
  PlayerState get playerState => _audioPlayer.playerState;

  /// Plays a specific ayah from a surah.
  /// Uses timestamp_from and timestamp_to to play only the ayah portion.
  /// [isTransition] - if true, transitions smoothly without stopping (for surah repeat mode)
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    bool isTransition = false,
  }) async {
    try {
      // Get surah audio info
      final surahAudio = await _databaseService.getSurahAudio(surahNumber);
      if (surahAudio == null) {
        throw Exception('Surah audio not found for surah $surahNumber');
      }

      // Get ayah segment info
      final ayahSegment = await _databaseService.getAyahSegment(
        surahNumber,
        ayahNumber,
      );
      if (ayahSegment == null) {
        throw Exception(
          'Ayah segment not found for surah $surahNumber, ayah $ayahNumber',
        );
      }

      // Cancel existing position subscription FIRST to prevent callbacks during stop
      await _positionSubscription?.cancel();

      // For transitions, we want to continue playing smoothly without stopping
      if (isTransition &&
          _audioPlayer.playing &&
          _currentSurahAudio?.surahNumber == surahNumber) {
        // Same surah - just update the ayah segment and seek to new start
        // This keeps the player in "playing" state during transitions
        _currentAyahSegment = ayahSegment;

        final startTime = Duration(milliseconds: ayahSegment.timestampFrom);
        // Seek to new start position while still playing
        await _audioPlayer.seek(startTime);
      } else {
        // Normal play or different surah - stop first, then play
        // Stop current playback if any - this cleans up the player state
        await stop();

        // Wait a moment after stop to ensure cleanup completes before loading new audio
        await Future.delayed(const Duration(milliseconds: 100));

        // Set current surah and ayah
        _currentSurahAudio = surahAudio;
        _currentAyahSegment = ayahSegment;

        // Load the audio URL
        await _audioPlayer.setUrl(surahAudio.audioUrl);

        // Set playback range to play only the ayah
        final startTime = Duration(milliseconds: ayahSegment.timestampFrom);

        // Seek to start position
        await _audioPlayer.seek(startTime);
      }

      // Set playback range (for both transition and normal play)
      // Note: Position monitoring for endTime is handled by the provider
      // We don't need to do anything here - the provider's listener will handle transitions

      // Start playback only if not transitioning (transition keeps playing state)
      if (!isTransition) {
        await _audioPlayer.play();
      }
      // _isPlaying is now synced with _audioPlayer.playing
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error playing ayah: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Plays a full surah from the beginning.
  Future<void> playSurah(int surahNumber) async {
    try {
      // Get surah audio info
      final surahAudio = await _databaseService.getSurahAudio(surahNumber);
      if (surahAudio == null) {
        throw Exception('Surah audio not found for surah $surahNumber');
      }

      // Cancel existing position subscription FIRST to prevent callbacks during stop
      await _positionSubscription?.cancel();

      // Stop current playback if any - this cleans up the player state
      await stop();

      // Wait a moment after stop to ensure cleanup completes before loading new audio
      await Future.delayed(const Duration(milliseconds: 100));

      // Set current surah
      _currentSurahAudio = surahAudio;
      _currentAyahSegment = null;

      // Load and play the audio URL
      await _audioPlayer.setUrl(surahAudio.audioUrl);
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      // _isPlaying is now synced with _audioPlayer.playing
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error playing surah: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Pauses current playback.
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      // _isPlaying is now synced with _audioPlayer.playing
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error pausing audio: $e');
      }
    }
  }

  /// Resumes current playback.
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      // _isPlaying is now synced with _audioPlayer.playing
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resuming audio: $e');
      }
    }
  }

  /// Stops current playback and resets position.
  Future<void> stop() async {
    try {
      // Cancel position subscription first to prevent callbacks during stop
      await _positionSubscription?.cancel();

      // Stop the player and wait for it to complete
      try {
        await _audioPlayer.stop();
      } catch (e) {
        // Ignore stop errors (player might already be stopped)
        if (kDebugMode) {
          debugPrint('Warning: Error stopping player: $e');
        }
      }

      // Wait a moment for cleanup
      await Future.delayed(const Duration(milliseconds: 50));

      // Reset position and state
      try {
        await _audioPlayer.seek(Duration.zero);
      } catch (e) {
        // Ignore seek errors if player is not ready
        if (kDebugMode) {
          debugPrint('Warning: Error seeking to zero: $e');
        }
      }

      _currentSurahAudio = null;
      _currentAyahSegment = null;
      // _isPlaying is now synced with _audioPlayer.playing (will be false after stop)
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping audio: $e');
      }
    }
  }

  /// Seeks to a specific position.
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error seeking audio: $e');
      }
    }
  }

  /// Sets playback speed (0.5x to 2.0x).
  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting playback speed: $e');
      }
    }
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _audioPlayer.dispose();
  }
}
