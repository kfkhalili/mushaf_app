import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/constants.dart';

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
              // Return a temporary directory for tests
              return Directory.systemTemp.path;
            }
            throw UnimplementedError();
          },
        );
  });

  tearDownAll(() {
    // Clear mock handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  group('AppDataService', () {
    late AppDataService service;

    setUp(() {
      service = AppDataService();
    });

    tearDown(() async {
      await service.close();
    });

    test('initializes database successfully', () async {
      await service.ensureInitialized();
      expect(service.database, isNotNull);
    });

    test('creates memorization_sessions table', () async {
      await service.ensureInitialized();
      final db = service.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [DbConstants.memorizationSessionsTable],
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], DbConstants.memorizationSessionsTable);
    });

    test('creates bookmarks table', () async {
      await service.ensureInitialized();
      final db = service.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [DbConstants.bookmarksTable],
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], DbConstants.bookmarksTable);
    });

    test('creates reading_sessions table', () async {
      await service.ensureInitialized();
      final db = service.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [DbConstants.readingSessionsTable],
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], DbConstants.readingSessionsTable);
    });

    test('creates user_preferences table', () async {
      await service.ensureInitialized();
      final db = service.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [DbConstants.userPreferencesTable],
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], DbConstants.userPreferencesTable);
    });

    test('creates all required indexes', () async {
      await service.ensureInitialized();
      final db = service.database;

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index'",
      );

      final indexNames = indexes.map((row) => row['name'] as String).toList();

      // Check memorization indexes
      expect(
        indexNames.any((name) => name.contains('memorization_sessions')),
        isTrue,
      );

      // Check bookmarks indexes
      expect(indexNames.any((name) => name.contains('bookmarks')), isTrue);

      // Check reading sessions indexes
      expect(
        indexNames.any((name) => name.contains('reading_sessions')),
        isTrue,
      );
    });

    test('handles concurrent initialization', () async {
      final futures = List.generate(5, (_) => service.ensureInitialized());

      await Future.wait(futures);

      expect(service.database, isNotNull);
    });

    test('throws StateError when accessing database before initialization', () {
      expect(() => service.database, throwsStateError);
    });

    test('can close and reinitialize', () async {
      await service.ensureInitialized();
      expect(service.database, isNotNull);

      await service.close();

      await service.ensureInitialized();
      expect(service.database, isNotNull);
    });
  });
}
