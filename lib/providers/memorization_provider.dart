import 'package:flutter_riverpod/legacy.dart';
import '../memorization/models.dart';
import '../services/memorization_service.dart';
import '../services/memorization_storage.dart';

class MemorizationSessionNotifier
    extends StateNotifier<MemorizationSessionState?> {
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
    state = MemorizationSessionState(
      pageNumber: pageNumber,
      window: AyahWindowState(
        ayahIndices: [firstAyahIndex],
        opacities: const [1.0],
        tapsSinceReveal: const [0],
      ),
      lastAyahIndexShown: firstAyahIndex,
      lastUpdatedAt: DateTime.now(),
      passCount: 0,
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

  Future<void> onTap({required int totalAyatOnPage}) async {
    if (state == null) return;

    final next = _service.applyTap(
      state: state!,
      config: _config,
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
    StateNotifierProvider<
      MemorizationSessionNotifier,
      MemorizationSessionState?
    >((ref) {
      return MemorizationSessionNotifier();
    });
