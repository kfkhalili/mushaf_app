import '../memorization/models.dart';

/// Pure helpers for chaining transitions. All functions are deterministic and side-effect free.
class MemorizationService {
  const MemorizationService();

  /// Applies a single valid tap: fades opacities and computes potential reveals/slides.
  MemorizationSessionState applyTap({
    required MemorizationSessionState state,
    required MemorizationConfig config,
    required int totalAyatOnPage,
  }) {
    final fade = config.fadeStepPerTap;

    // Fade visible ayat
    final fadedOpacities = state.window.opacities
        .map((o) => (o - fade).clamp(0.0, 1.0))
        .toList(growable: false);

    var window = state.window.copyWith(opacities: fadedOpacities);
    var lastShown = state.lastAyahIndexShown;

    // Reveal logic
    window = _maybeRevealNext(
      window: window,
      lastAyahIndexShown: lastShown,
      totalAyatOnPage: totalAyatOnPage,
      config: config,
      onRevealed: (int revealedIndex) {
        lastShown = revealedIndex;
      },
    );

    // Slide window if oldest fully faded
    if (window.ayahIndices.isNotEmpty && window.opacities.first <= 0.0) {
      final newIndices = window.ayahIndices.sublist(1);
      final newOpacities = window.opacities.sublist(1);
      final newTaps = window.tapsSinceReveal.sublist(1);
      window = window.copyWith(
        ayahIndices: newIndices,
        opacities: newOpacities,
        tapsSinceReveal: newTaps,
      );
    }

    return state.copyWith(
      window: window,
      lastAyahIndexShown: lastShown,
      lastUpdatedAt: DateTime.now(),
    );
  }

  AyahWindowState _maybeRevealNext({
    required AyahWindowState window,
    required int lastAyahIndexShown,
    required int totalAyatOnPage,
    required MemorizationConfig config,
    required void Function(int revealedIndex) onRevealed,
  }) {
    if (window.ayahIndices.isEmpty) return window;

    final newest = window.ayahIndices.last;

    // Try reveal next (n+1)
    if (newest + 1 < totalAyatOnPage) {
      final oldestOpacity = window.opacities.first;
      final canRevealNext = oldestOpacity <= config.revealThresholdNext;
      if (canRevealNext &&
          window.ayahIndices.length < config.visibleWindowSize) {
        final nextIndex = newest + 1;
        window = AyahWindowState(
          ayahIndices: [...window.ayahIndices, nextIndex],
          opacities: [...window.opacities, 1.0],
          tapsSinceReveal: [...window.tapsSinceReveal, 0],
        );
        onRevealed(nextIndex);
      }
    }

    // Try reveal second next (n+2) when window already has 2+ ayat
    if (window.ayahIndices.length >= 2) {
      final oldestOpacity = window.opacities.first;
      final secondOpacity = window.opacities[1];
      final latest = window.ayahIndices.last;
      if (latest + 1 < totalAyatOnPage) {
        final canRevealSecondNext =
            oldestOpacity <= config.revealThresholdSecondNext &&
            secondOpacity <= config.revealThresholdNext;
        final withinWindow =
            window.ayahIndices.length < config.visibleWindowSize;
        if (canRevealSecondNext && withinWindow) {
          final nextIndex = latest + 1;
          window = AyahWindowState(
            ayahIndices: [...window.ayahIndices, nextIndex],
            opacities: [...window.opacities, 1.0],
            tapsSinceReveal: [...window.tapsSinceReveal, 0],
          );
          onRevealed(nextIndex);
        }
      }
    }

    return window;
  }
}
