import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers/memorization_provider.dart';

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
  });
}
