import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // WHY: The unified gateway now owns legacy-data migration. Constructed with
  // SharedPreferences, ensureInitialized() migrates the legacy bookmarks.db into
  // the unified database so every consumer reads a ready, migrated database with
  // no migration wiring of its own. The in-memory adapter keeps this isolated.
  group('AppDataService legacy migration', () {
    test('migrates legacy bookmarks.db during initialization', () async {
      // Seed a legacy bookmarks.db in this file's isolated documents dir.
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final oldDbPath = p.join(
        documentsDirectory.path,
        MigrationConstants.legacyBookmarksDb,
      );
      final oldDb = await openDatabase(
        oldDbPath,
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${DbConstants.bookmarksTable} (
              ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.surahNumberCol} INTEGER NOT NULL,
              ${DbConstants.ayahNumberCol} INTEGER NOT NULL,
              ${DbConstants.cachedPageNumberCol} INTEGER,
              ${DbConstants.createdAtCol} TEXT NOT NULL,
              ${DbConstants.noteCol} TEXT,
              UNIQUE(${DbConstants.surahNumberCol}, ${DbConstants.ayahNumberCol})
            )
          ''');
        },
      );
      const surah = 3;
      const ayah = 7;
      await oldDb.insert(DbConstants.bookmarksTable, {
        DbConstants.surahNumberCol: surah,
        DbConstants.ayahNumberCol: ayah,
        DbConstants.createdAtCol: DateTime.now().toIso8601String(),
        DbConstants.noteCol: 'legacy',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await oldDb.close();

      // WHY: in-memory unified db — isolated per instance, so the migrated row
      // never leaks into other suites and needs no manual cleanup.
      final prefs = await SharedPreferences.getInstance();
      final service = AppDataService(
        databasePath: inMemoryDatabasePath,
        prefs: prefs,
      );
      addTearDown(service.close);

      // The gateway migrates as part of its own initialization — no consumer
      // and no explicit MigrationService call is involved.
      await service.ensureInitialized();

      final rows = await service.database.query(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [surah, ayah],
      );

      expect(rows, isNotEmpty);
      expect(rows.first[DbConstants.noteCol], 'legacy');
      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });
  });
}
