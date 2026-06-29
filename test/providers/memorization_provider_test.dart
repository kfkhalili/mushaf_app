import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';
import 'package:mushaf_app/memorization/models.dart';
import '../support/harness.dart';

/// A one-ayah page (two words of surah 1, ayah 1) so the layout resolves to a
/// single ayah — used to drive [MemorizationSessionNotifier.handleTap] to
/// completion with a full-fade config.
PageData _singleAyahPageData(int pageNumber) {
  return PageData(
    layout: PageLayout(
      pageNumber: pageNumber,
      lines: const [
        LineInfo(
          lineNumber: 1,
          lineType: 'ayah',
          isCentered: false,
          surahNumber: 1,
          words: [
            Word(text: 'بِسْمِ', surahNumber: 1, ayahNumber: 1),
            Word(text: 'اللَّهِ', surahNumber: 1, ayahNumber: 1),
          ],
        ),
      ],
    ),
    pageFontFamily: 'Page$pageNumber',
    pageSurahName: 'الفاتحة',
    pageSurahNumber: 1,
    juzNumber: 1,
    hizbNumber: 1,
  );
}

void main() {
  useDatabaseTestEnv();
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

    test('onTap reports stay while the page is incomplete', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memorizationSessionProvider.notifier);
      await notifier.startSession(pageNumber: 1, firstAyahIndex: 0);

      final outcome = await notifier.onTap(totalAyatOnPage: 7);
      expect(outcome, MemorizationTapOutcome.stay);
    });

    test(
      'onTap reports advanceToNextPage once the last ayah fades away',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(memorizationSessionProvider.notifier);
        // Full-fade config: one tap empties the window on a single-ayah page,
        // which is also the last ayah — so the page is complete.
        notifier.setConfig(const MemorizationConfig(fadeStepPerTap: 1.0));
        await notifier.startSession(pageNumber: 1, firstAyahIndex: 0);

        final outcome = await notifier.onTap(totalAyatOnPage: 1);
        expect(outcome, MemorizationTapOutcome.advanceToNextPage);
      },
    );

    test('onTap reports stay when there is no session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final outcome = await container
          .read(memorizationSessionProvider.notifier)
          .onTap(totalAyatOnPage: 7);
      expect(outcome, MemorizationTapOutcome.stay);
    });

    // WHY: handleTap is the deep entry point — it counts the ayat on the page,
    // decides, and owns the page turn. These tests exercise the page-advance
    // behaviour the reader screen used to carry, directly through the notifier
    // interface (no widget pump). totalPagesProvider is overridden so the test
    // does not spin up DatabaseService / bundled assets.
    test(
      'handleTap advances the page and resumes when the page completes',
      () async {
        final container = ProviderContainer(
          overrides: [totalPagesProvider.overrideWith((ref) async => 604)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(memorizationSessionProvider.notifier);
        // Full-fade config: a single tap completes a one-ayah page.
        notifier.setConfig(const MemorizationConfig(fadeStepPerTap: 1.0));
        await notifier.startSession(pageNumber: 1, firstAyahIndex: 0);

        await notifier.handleTap(pageData: _singleAyahPageData(1));

        expect(container.read(currentPageProvider), 2);
        expect(container.read(memorizationSessionProvider)?.pageNumber, 2);
      },
    );

    test('handleTap does not advance past the last page', () async {
      final container = ProviderContainer(
        overrides: [totalPagesProvider.overrideWith((ref) async => 1)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(memorizationSessionProvider.notifier);
      notifier.setConfig(const MemorizationConfig(fadeStepPerTap: 1.0));
      await notifier.startSession(pageNumber: 1, firstAyahIndex: 0);

      await notifier.handleTap(pageData: _singleAyahPageData(1));

      // Page 1 is the last page → stay put, session unchanged.
      expect(container.read(currentPageProvider), 1);
      expect(container.read(memorizationSessionProvider)?.pageNumber, 1);
    });
  });
}
