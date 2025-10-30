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

    // Increment per-ayah tap counters to enforce minimum one tap between reveals
    final incrementedTaps = state.window.tapsSinceReveal
        .map((t) => t + 1)
        .toList(growable: false);

    var window = state.window.copyWith(
      opacities: fadedOpacities,
      tapsSinceReveal: incrementedTaps,
    );
    var lastShown = state.lastAyahIndexShown;

    // Reveal logic (at most one reveal per tap)
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
    final tapsSinceNewestReveal = window.tapsSinceReveal.isNotEmpty
        ? window.tapsSinceReveal.last
        : 0;

    // Enforce fixed taps per reveal for consistency
    final bool enoughTapsForReveal =
        tapsSinceNewestReveal >= config.tapsPerReveal;

    // Try reveal next (n+1) - allow at most one reveal per tap
    if (newest + 1 < totalAyatOnPage) {
      final canRevealNext = enoughTapsForReveal;
      if (canRevealNext &&
          window.ayahIndices.length < config.visibleWindowSize) {
        final nextIndex = newest + 1;
        window = AyahWindowState(
          ayahIndices: [...window.ayahIndices, nextIndex],
          opacities: [...window.opacities, 1.0],
          // Reset tap counter for the newly revealed ayah
          tapsSinceReveal: [...window.tapsSinceReveal, 0],
        );
        onRevealed(nextIndex);

        // Do NOT reveal another ayah in the same tap
        return window;
      }
    }

    return window;
  }
}
