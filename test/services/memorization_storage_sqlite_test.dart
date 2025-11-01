import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/services/memorization_storage_sqlite.dart';
import 'package:mushaf_app/memorization/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize sqflite for testing (required for non-device tests)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return Directory.systemTemp.path;
            }
            throw UnimplementedError();
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

  group('SqliteMemorizationStorage', () {
    late AppDataService appDataService;
    late SqliteMemorizationStorage storage;

    setUp(() {
      appDataService = AppDataService();
      storage = SqliteMemorizationStorage(appDataService);
    });

    tearDown(() async {
      await appDataService.close();
    });

    test('saves and loads memorization session', () async {
      final session = MemorizationSessionState(
        pageNumber: 1,
        window: const AyahWindowState(
          ayahIndices: [0, 1, 2],
          opacities: [1.0, 0.5, 0.0],
          tapsSinceReveal: [0, 1, 0],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(session);

      final loaded = await storage.loadSession(1);

      expect(loaded, isNotNull);
      expect(loaded?.pageNumber, 1);
      expect(loaded?.window.ayahIndices, [0, 1, 2]);
      expect(loaded?.window.opacities, [1.0, 0.5, 0.0]);
      expect(loaded?.window.tapsSinceReveal, [0, 1, 0]);
      expect(loaded?.lastAyahIndexShown, 1);
      expect(loaded?.passCount, 0);
    });

    test('returns null when loading non-existent session', () async {
      final loaded = await storage.loadSession(999);
      expect(loaded, isNull);
    });

    test('clears session correctly', () async {
      final session = MemorizationSessionState(
        pageNumber: 5,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(session);
      expect(await storage.loadSession(5), isNotNull);

      await storage.clearSession(5);
      expect(await storage.loadSession(5), isNull);
    });

    test('updates existing session when saving again', () async {
      final session1 = MemorizationSessionState(
        pageNumber: 10,
        window: const AyahWindowState(
          ayahIndices: [0],
          opacities: [1.0],
          tapsSinceReveal: [0],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(session1);

      final session2 = MemorizationSessionState(
        pageNumber: 10,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 0.5],
          tapsSinceReveal: [0, 1],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 1,
      );

      await storage.saveSession(session2);

      final loaded = await storage.loadSession(10);
      expect(loaded?.window.ayahIndices, [0, 1]);
      expect(loaded?.passCount, 1);
    });

    test('handles multiple sessions independently', () async {
      final session1 = MemorizationSessionState(
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

      final session2 = MemorizationSessionState(
        pageNumber: 2,
        window: const AyahWindowState(
          ayahIndices: [0, 1],
          opacities: [1.0, 0.5],
          tapsSinceReveal: [0, 1],
        ),
        lastAyahIndexShown: 1,
        lastUpdatedAt: DateTime.now(),
        passCount: 1,
      );

      await storage.saveSession(session1);
      await storage.saveSession(session2);

      final loaded1 = await storage.loadSession(1);
      final loaded2 = await storage.loadSession(2);

      expect(loaded1?.pageNumber, 1);
      expect(loaded1?.passCount, 0);
      expect(loaded2?.pageNumber, 2);
      expect(loaded2?.passCount, 1);
    });

    test('handles empty ayahIndices array', () async {
      final session = MemorizationSessionState(
        pageNumber: 3,
        window: const AyahWindowState(
          ayahIndices: [],
          opacities: [],
          tapsSinceReveal: [],
        ),
        lastAyahIndexShown: 0,
        lastUpdatedAt: DateTime.now(),
        passCount: 0,
      );

      await storage.saveSession(session);

      final loaded = await storage.loadSession(3);
      expect(loaded?.window.ayahIndices, isEmpty);
    });
  });
}
