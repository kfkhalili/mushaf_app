import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('MemorizationProvider', () {
    test('memorizationSessionProvider initializes to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(memorizationSessionProvider), isNull);
    });

    test('isActive returns false when no session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memorizationSessionProvider.notifier);
      expect(notifier.isActive, isFalse);
    });

    test('startSession creates new session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(memorizationSessionProvider.notifier)
          .startSession(pageNumber: 1, firstAyahIndex: 0);

      final session = container.read(memorizationSessionProvider);
      expect(session, isNotNull);
      expect(session?.pageNumber, 1);
      expect(session?.window.ayahIndices, [0]);
    });

    test('endSession clears session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(memorizationSessionProvider.notifier)
          .startSession(pageNumber: 1, firstAyahIndex: 0);

      await container.read(memorizationSessionProvider.notifier).endSession();

      expect(container.read(memorizationSessionProvider), isNull);
    });

    test('onTap updates session state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(memorizationSessionProvider.notifier)
          .startSession(pageNumber: 1, firstAyahIndex: 0);

      await container
          .read(memorizationSessionProvider.notifier)
          .onTap(totalAyatOnPage: 7);

      // Session should still exist after tap
      final session = container.read(memorizationSessionProvider);
      expect(session, isNotNull);
    });

    test('startSession with different firstAyahIndex', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(memorizationSessionProvider.notifier)
          .startSession(pageNumber: 1, firstAyahIndex: 5);

      final session = container.read(memorizationSessionProvider);
      expect(session?.window.ayahIndices.first, 5);
      expect(session?.lastAyahIndexShown, 5);
    });

    test('onTap does nothing when session is null', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(memorizationSessionProvider), isNull);
      await container
          .read(memorizationSessionProvider.notifier)
          .onTap(totalAyatOnPage: 7);
      expect(container.read(memorizationSessionProvider), isNull);
    });

    test('endSession when no session exists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(memorizationSessionProvider), isNull);
      await container.read(memorizationSessionProvider.notifier).endSession();
      expect(container.read(memorizationSessionProvider), isNull);
    });

    test('multiple taps progress memorization correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(memorizationSessionProvider.notifier)
          .startSession(pageNumber: 1, firstAyahIndex: 0);

      final initialState = container.read(memorizationSessionProvider)!;

      // First tap
      await container
          .read(memorizationSessionProvider.notifier)
          .onTap(totalAyatOnPage: 7);

      final afterFirstTap = container.read(memorizationSessionProvider);
      expect(afterFirstTap, isNot(initialState));

      // Second tap
      await container
          .read(memorizationSessionProvider.notifier)
          .onTap(totalAyatOnPage: 7);

      final afterSecondTap = container.read(memorizationSessionProvider);
      expect(afterSecondTap, isNot(afterFirstTap));
    });
  });
}
