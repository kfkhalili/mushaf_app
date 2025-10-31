import '../memorization/models.dart';

/// Pure helpers for memorization transitions. All functions are deterministic and side-effect free.
class MemorizationService {
  const MemorizationService();

  /// Starts a new memorization session
  MemorizationSessionState startSession({
    required int pageNumber,
    required int firstAyahIndex,
    required MemorizationConfig config,
  }) {
    return MemorizationSessionState(
      pageNumber: pageNumber,
      window: AyahWindowState(
        ayahIndices: [firstAyahIndex],
        isHidden: [config.startWithTextHidden], // Start hidden
        masteryLevel: [0], // Not reviewed
        reviewCount: [0], // No reviews
      ),
      currentAyahIndex: firstAyahIndex,
      lastUpdatedAt: DateTime.now(),
      totalPasses: 0,
    );
  }

  /// Reveals the current ayah text
  MemorizationSessionState revealAyah({
    required MemorizationSessionState state,
    required int ayahIndex,
  }) {
    final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
    if (ayahPos == -1) return state;

    final newIsHidden = List<bool>.from(state.window.isHidden);
    newIsHidden[ayahPos] = false; // Reveal

    return state.copyWith(
      window: state.window.copyWith(isHidden: newIsHidden),
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Hides the current ayah text
  MemorizationSessionState hideAyah({
    required MemorizationSessionState state,
    required int ayahIndex,
  }) {
    final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
    if (ayahPos == -1) return state;

    final newIsHidden = List<bool>.from(state.window.isHidden);
    newIsHidden[ayahPos] = true; // Hide

    return state.copyWith(
      window: state.window.copyWith(isHidden: newIsHidden),
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Grades an ayah and moves to next ayah
  MemorizationSessionState gradeAyah({
    required MemorizationSessionState state,
    required int ayahIndex,
    required int masteryLevel, // 1=Hard, 2=Medium, 3=Easy
    required int totalAyatOnPage,
    required MemorizationConfig config,
  }) {
    final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
    if (ayahPos == -1) return state;

    // Update mastery level and review count
    final newMasteryLevel = List<int>.from(state.window.masteryLevel);
    final newReviewCount = List<int>.from(state.window.reviewCount);

    newMasteryLevel[ayahPos] = masteryLevel;
    newReviewCount[ayahPos] = (newReviewCount[ayahPos]) + 1;

    // Hide the ayah again (for future review)
    final newIsHidden = List<bool>.from(state.window.isHidden);
    newIsHidden[ayahPos] = true;

    // Move to next ayah
    int nextIndex = state.currentAyahIndex + 1;

    // Check if next ayah needs to be added to window
    final window = state.window;
    if (!window.ayahIndices.contains(nextIndex) && nextIndex < totalAyatOnPage) {
      // Add next ayah to window (hidden by default)
      final newIndices = [...window.ayahIndices, nextIndex];
      final newIsHiddenForNew = [...newIsHidden, config.startWithTextHidden];
      final newMasteryForNew = [...newMasteryLevel, 0]; // Not reviewed yet
      final newReviewForNew = [...newReviewCount, 0]; // No reviews yet

      // Maintain window size (remove oldest if needed)
      if (newIndices.length > config.visibleWindowSize) {
        newIndices.removeAt(0);
        newIsHiddenForNew.removeAt(0);
        newMasteryForNew.removeAt(0);
        newReviewForNew.removeAt(0);
      }

      return state.copyWith(
        window: AyahWindowState(
          ayahIndices: newIndices,
          isHidden: newIsHiddenForNew,
          masteryLevel: newMasteryForNew,
          reviewCount: newReviewForNew,
        ),
        currentAyahIndex: nextIndex,
        lastUpdatedAt: DateTime.now(),
      );
    }

    // If next ayah already in window, just update current index and window state
    final finalNextIndex = nextIndex < totalAyatOnPage ? nextIndex : state.currentAyahIndex;

    return state.copyWith(
      window: window.copyWith(
        isHidden: newIsHidden,
        masteryLevel: newMasteryLevel,
        reviewCount: newReviewCount,
      ),
      currentAyahIndex: finalNextIndex,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Navigates to the previous ayah in the window
  MemorizationSessionState navigateToPreviousAyah({
    required MemorizationSessionState state,
  }) {
    final currentPos = state.window.ayahIndices.indexOf(state.currentAyahIndex);
    if (currentPos <= 0) return state;

    final prevIndex = state.window.ayahIndices[currentPos - 1];
    return state.copyWith(
      currentAyahIndex: prevIndex,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Navigates to the next ayah in the window
  MemorizationSessionState navigateToNextAyah({
    required MemorizationSessionState state,
    required int totalAyatOnPage,
  }) {
    final currentPos = state.window.ayahIndices.indexOf(state.currentAyahIndex);
    if (currentPos == -1 || currentPos >= state.window.ayahIndices.length - 1) {
      return state;
    }

    final nextIndex = state.window.ayahIndices[currentPos + 1];
    if (nextIndex >= totalAyatOnPage) return state;

    return state.copyWith(
      currentAyahIndex: nextIndex,
      lastUpdatedAt: DateTime.now(),
    );
  }
}
