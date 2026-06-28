import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/memorization/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up mock SharedPreferences for migration service
    SharedPreferences.setMockInitialValues({});

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return Directory.systemTemp.path;
            }
            return null;
          },
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

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
  });
}
