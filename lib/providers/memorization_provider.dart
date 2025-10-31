import 'package:flutter_riverpod/legacy.dart';
import '../memorization/models.dart';
import '../services/memorization_service.dart';
import '../services/memorization_storage.dart';

class MemorizationSessionNotifier extends StateNotifier<MemorizationSessionState?> {
  MemorizationSessionNotifier({MemorizationStorage? storage})
      : _storage = storage ?? InMemoryMemorizationStorage(),
        super(null);

  final MemorizationService _service = const MemorizationService();
  final MemorizationStorage _storage;
  MemorizationConfig _config = const MemorizationConfig();

  void setConfig(MemorizationConfig config) {
    _config = config;
  }

  Future<void> resumeIfExists(int pageNumber) async {
    final loaded = await _storage.loadSession(pageNumber);
    if (loaded != null) {
      state = loaded;
    }
  }

  Future<void> startSession({
    required int pageNumber,
    required int firstAyahIndex,
  }) async {
    state = _service.startSession(
      pageNumber: pageNumber,
      firstAyahIndex: firstAyahIndex,
      config: _config,
    );
    await _maybePersist();
  }

  bool get isActive => state != null;

  Future<void> endSession() async {
    final page = state?.pageNumber;
    state = null;
    if (page != null) {
      await _storage.clearSession(page);
    }
  }

  /// Reveals the current ayah
  Future<void> revealAyah(int ayahIndex) async {
    if (state == null) return;

    final next = _service.revealAyah(
      state: state!,
      ayahIndex: ayahIndex,
    );

    state = next;
    await _maybePersist();
  }

  /// Hides the current ayah
  Future<void> hideAyah(int ayahIndex) async {
    if (state == null) return;

    final next = _service.hideAyah(
      state: state!,
      ayahIndex: ayahIndex,
    );

    state = next;
    await _maybePersist();
  }

  /// Grades an ayah and moves to next
  Future<void> gradeAyah({
    required int ayahIndex,
    required int masteryLevel, // 1=Hard, 2=Medium, 3=Easy
    required int totalAyatOnPage,
  }) async {
    if (state == null) return;

    final next = _service.gradeAyah(
      state: state!,
      ayahIndex: ayahIndex,
      masteryLevel: masteryLevel,
      totalAyatOnPage: totalAyatOnPage,
      config: _config,
    );

    state = next;
    await _maybePersist();
  }

  /// Navigates to the previous ayah
  Future<void> navigateToPreviousAyah() async {
    if (state == null) return;

    final next = _service.navigateToPreviousAyah(state: state!);
    state = next;
    await _maybePersist();
  }

  /// Navigates to the next ayah
  Future<void> navigateToNextAyah({required int totalAyatOnPage}) async {
    if (state == null) return;

    final next = _service.navigateToNextAyah(
      state: state!,
      totalAyatOnPage: totalAyatOnPage,
    );
    state = next;
    await _maybePersist();
  }

  Future<void> _maybePersist() async {
    if (state == null) return;
    await _storage.saveSession(state!);
  }
}

final memorizationSessionProvider =
    StateNotifierProvider<MemorizationSessionNotifier, MemorizationSessionState?>((ref) {
  return MemorizationSessionNotifier();
});
