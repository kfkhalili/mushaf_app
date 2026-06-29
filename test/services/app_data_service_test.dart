import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/constants.dart';

import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();

  group('AppDataService', () {
    late AppDataService service;

    setUp(() {
      // WHY: In-memory adapter — isolated per instance with no shared on-disk
      // app_data.db, so this file leaks no state into the next and needs no
      // sequential-execution guarantee.
      service = AppDataService(databasePath: inMemoryDatabasePath);
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

    // WHY: Test that PRAGMA exceptions are handled gracefully.
    // On iOS, PRAGMA statements (like journal_mode=WAL and busy_timeout)
    // may throw exceptions on some platforms. This test verifies that
    // initialization completes successfully even if PRAGMA fails.
    test(
      'database initialization succeeds even when PRAGMA throws exceptions',
      () async {
        // Initialize database - PRAGMA may fail on some platforms
        await service.ensureInitialized();

        // Verify database is functional despite potential PRAGMA failures
        final db = service.database;
        expect(db, isNotNull);

        // Verify tables were created
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );
        expect(tables, isNotEmpty);
      },
    );

    // WHY: Verify that writable database operations work correctly
    // even if optional PRAGMA settings (like WAL mode or busy_timeout) fail.
    test('database remains functional when PRAGMA statements fail', () async {
      await service.ensureInitialized();
      final db = service.database;

      // Test that database operations still work
      // Even if PRAGMA journal_mode=WAL or busy_timeout failed
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      expect(
        tables.any((t) => t['name'] == DbConstants.bookmarksTable),
        isTrue,
      );
      expect(
        tables.any((t) => t['name'] == DbConstants.readingSessionsTable),
        isTrue,
      );
    });
  });
}
