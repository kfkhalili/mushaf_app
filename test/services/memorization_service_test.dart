import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/services/memorization_service.dart';
import 'package:mushaf_app/memorization/models.dart';

void main() {
  group('MemorizationService', () {
    late MemorizationService service;

    setUp(() {
      service = const MemorizationService();
    });

    test('applyTap fades opacities correctly', () {
      const config = MemorizationConfig();
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 1.0],
          tapsSinceReveal: [0, 0],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Opacities should be faded
      expect(result.window.opacities.first, lessThan(1.0));
      expect(result.window.opacities.last, lessThan(1.0));
    });

    test('applyTap increments tap counters', () {
      const config = MemorizationConfig();
      // Use tap counters that won't trigger reveals
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 1.0],
          tapsSinceReveal: [1, 2], // Not enough to trigger reveal
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Tap counters should be incremented (no reveals, so both incremented)
      expect(result.window.tapsSinceReveal.first, 2);
      expect(result.window.tapsSinceReveal.last, 3);
    });

    test('applyTap reveals next ayah when enough taps', () {
      const config = MemorizationConfig();
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [config.tapsPerReveal - 1], // One less than needed, will be incremented
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Next ayah should be revealed (tap counter was incremented first, then reveal happened)
      expect(result.window.ayahIndices.length, 2);
      expect(result.window.ayahIndices.last, 1);
      expect(result.lastAyahIndexShown, 1);
      // Newly revealed ayah should have tap counter reset to 0
      expect(result.window.tapsSinceReveal.last, 0);
    });

    test('applyTap slides window when oldest ayah fades completely', () {
      const config = MemorizationConfig();
      // Create state where first ayah will fade to 0
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [config.fadeStepPerTap, 1.0], // First will become 0
          tapsSinceReveal: [0, 0],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Window should slide (oldest removed)
      expect(result.window.ayahIndices.length, 1);
      expect(result.window.ayahIndices.first, 1);
    });

    test('applyTap respects visibleWindowSize limit', () {
      final config = MemorizationConfig(visibleWindowSize: 2);
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 1.0],
          tapsSinceReveal: [config.tapsPerReveal, config.tapsPerReveal],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Should not reveal beyond window size
      expect(result.window.ayahIndices.length, lessThanOrEqualTo(2));
    });

    test('applyTap handles empty window', () {
      const config = MemorizationConfig();
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [],
          opacities: [],
          tapsSinceReveal: [],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Should handle gracefully
      expect(result.window.ayahIndices, isEmpty);
    });

    test('applyTap updates lastUpdatedAt', () {
      const config = MemorizationConfig();
      final oldTime = DateTime(2024, 1, 1);
      final initialState = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: oldTime,
        passCount: 0,
      );

      final result = service.applyTap(
        state: initialState,
        config: config,
        totalAyatOnPage: 7,
      );

      // Should update timestamp
      expect(result.lastUpdatedAt.isAfter(oldTime), isTrue);
    });
  });
}

