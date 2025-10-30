import '../memorization/models.dart';

abstract class MemorizationStorage {
  Future<void> saveSession(MemorizationSessionState state);
  Future<MemorizationSessionState?> loadSession(int pageNumber);
  Future<void> clearSession(int pageNumber);
}

class InMemoryMemorizationStorage implements MemorizationStorage {
  static final Map<int, MemorizationSessionState> _byPage = {};

  @override
  Future<void> saveSession(MemorizationSessionState state) async {
    _byPage[state.pageNumber] = state;
  }

  @override
  Future<MemorizationSessionState?> loadSession(int pageNumber) async {
    return _byPage[pageNumber];
  }

  @override
  Future<void> clearSession(int pageNumber) async {
    _byPage.remove(pageNumber);
  }
}
