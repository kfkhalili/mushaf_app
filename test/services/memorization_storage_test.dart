import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/services/memorization_storage.dart';
import 'package:mushaf_app/memorization/models.dart';

void main() {
  group('InMemoryMemorizationStorage', () {
    late InMemoryMemorizationStorage storage;

    setUp(() {
      storage = InMemoryMemorizationStorage();
      // Note: Cannot clear _byPage as it's private, but each test uses different page numbers
    });

    test('saveSession stores session state', () async {
      final state = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(state);
      final loaded = await storage.loadSession(1);

      expect(loaded, isNotNull);
      expect(loaded?.pageNumber, 1);
      expect(loaded?.window.ayahIndices, [0]);
    });

    test('loadSession returns null for non-existent session', () async {
      final loaded = await storage.loadSession(999);
      expect(loaded, isNull);
    });

    test('clearSession removes session', () async {
      final state = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(state);
      await storage.clearSession(1);
      final loaded = await storage.loadSession(1);

      expect(loaded, isNull);
    });

    test('saveSession overwrites existing session', () async {
      final state1 = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final state2 = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 1.0],
          tapsSinceReveal: [0, 0],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 1,
      );

      await storage.saveSession(state1);
      await storage.saveSession(state2);
      final loaded = await storage.loadSession(1);

      expect(loaded?.window.ayahIndices.length, 2);
      expect(loaded?.passCount, 1);
    });

    test('storage handles multiple pages independently', () async {
      final state1 = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final state2 = MemorizationSessionState(
        pageNumber: 2,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 1.0],
          tapsSinceReveal: [0, 0],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(state1);
      await storage.saveSession(state2);

      final loaded1 = await storage.loadSession(1);
      final loaded2 = await storage.loadSession(2);

      expect(loaded1?.pageNumber, 1);
      expect(loaded1?.window.ayahIndices.length, 1);
      expect(loaded2?.pageNumber, 2);
      expect(loaded2?.window.ayahIndices.length, 2);
    });
  });
}
