import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/services/migration_service.dart';
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

  group('MigrationService', () {
    late AppDataService appDataService;
    late MigrationService migrationService;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Clear migration flag for clean test state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_data_migrated_v1');

      appDataService = AppDataService();
      await appDataService.ensureInitialized();
      migrationService = MigrationService(appDataService);
    });

    tearDown(() async {
      // WHY: Clean up database tables before closing connection
      // Use transactions for atomic cleanup operations
      try {
        final db = appDataService.database;

        // WHY: Wrap cleanup in transaction for atomicity and better error handling
        await db.transaction((txn) async {
          // WHY: Use TRUNCATE-equivalent behavior by deleting all rows
          // Check if tables exist before attempting cleanup
          final tables = await txn.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN (?, ?, ?)",
            [
              DbConstants.bookmarksTable,
              DbConstants.readingSessionsTable,
              DbConstants.memorizationSessionsTable,
            ],
          );

          final tableNames = tables
              .map((row) => row['name'] as String)
              .toList();

          // WHY: Only delete from tables that exist to avoid errors
          if (tableNames.contains(DbConstants.bookmarksTable)) {
            await txn.delete(DbConstants.bookmarksTable);
          }
          if (tableNames.contains(DbConstants.readingSessionsTable)) {
            await txn.delete(DbConstants.readingSessionsTable);
          }
          if (tableNames.contains(DbConstants.memorizationSessionsTable)) {
            await txn.delete(DbConstants.memorizationSessionsTable);
          }
        });
      } catch (e) {
        // Ignore errors if database is already closed or tables don't exist
      }

      // WHY: Close connection before clearing preferences
      await appDataService.close();

      // WHY: Clear migration flag for next test
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_data_migrated_v1');

      // WHY: Small delay to ensure connection is fully closed before next test
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('does not migrate if already migrated', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_data_migrated_v1', true);

      await appDataService.ensureInitialized();
      await migrationService.migrateIfNeeded(prefs);

      // Verify migration flag is still set
      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });

    test('migrates bookmarks from old database', () async {
      // Create old bookmarks.db with test data
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final oldDbPath = p.join(documentsDirectory.path, 'bookmarks.db');

      final oldDb = await openDatabase(
        oldDbPath,
        version: 1,
        onCreate: (db, version) async {
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

      // Use unique surah:ayah to avoid conflicts
      const testSurah = 2;
      const testAyah = 2;

      // WHY: Use transaction to ensure atomic insert operation
      await oldDb.transaction((txn) async {
        // Insert test bookmark with conflict handling
        await txn.insert(DbConstants.bookmarksTable, {
          DbConstants.surahNumberCol: testSurah,
          DbConstants.ayahNumberCol: testAyah,
          DbConstants.cachedPageNumberCol: 2,
          DbConstants.createdAtCol: DateTime.now().toIso8601String(),
          DbConstants.noteCol: 'Test note',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });

      await oldDb.close();

      // WHY: Clear any existing data in new DB first using transaction
      final db = appDataService.database;
      await db.transaction((txn) async {
        // WHY: Check if record exists before deleting to avoid unnecessary operations
        final existing = await txn.query(
          DbConstants.bookmarksTable,
          columns: [DbConstants.idCol],
          where:
              '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
          whereArgs: [testSurah, testAyah],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          await txn.delete(
            DbConstants.bookmarksTable,
            where:
                '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
            whereArgs: [testSurah, testAyah],
          );
        }
      });

      // Run migration
      final prefs = await SharedPreferences.getInstance();
      await migrationService.migrateIfNeeded(prefs);

      // Verify bookmark was migrated
      final results = await db.query(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [testSurah, testAyah],
      );

      expect(results, isNotEmpty);
      expect(results.first[DbConstants.surahNumberCol], testSurah);
      expect(results.first[DbConstants.ayahNumberCol], testAyah);
      expect(results.first[DbConstants.noteCol], 'Test note');
    });

    test('migrates reading sessions from old database', () async {
      // Create old reading_progress.db with test data
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final oldDbPath = p.join(documentsDirectory.path, 'reading_progress.db');

      final oldDb = await openDatabase(
        oldDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${DbConstants.readingSessionsTable} (
              ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${DbConstants.sessionDateCol} TEXT NOT NULL,
              ${DbConstants.pageNumberCol} INTEGER NOT NULL,
              ${DbConstants.timestampCol} TEXT NOT NULL,
              ${DbConstants.durationSecondsCol} INTEGER
            )
          ''');
        },
      );

      // WHY: Use transaction for atomic insert operation
      final now = DateTime.now();
      await oldDb.transaction((txn) async {
        await txn.insert(DbConstants.readingSessionsTable, {
          DbConstants.sessionDateCol: now.toIso8601String().split('T')[0],
          DbConstants.pageNumberCol: 5,
          DbConstants.timestampCol: now.toIso8601String(),
          DbConstants.durationSecondsCol: 120,
        });
      });

      await oldDb.close();

      // Run migration
      await appDataService.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      await migrationService.migrateIfNeeded(prefs);

      // Verify reading session was migrated
      final newDb = appDataService.database;
      final results = await newDb.query(
        DbConstants.readingSessionsTable,
        where: '${DbConstants.pageNumberCol} = ?',
        whereArgs: [5],
      );

      expect(results, isNotEmpty);
      expect(results.first[DbConstants.pageNumberCol], 5);
      expect(results.first[DbConstants.durationSecondsCol], 120);
    });

    test('handles missing old databases gracefully', () async {
      // No old databases exist - should not crash
      await appDataService.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      await migrationService.migrateIfNeeded(prefs);

      // Migration should complete successfully
      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });

    test('sets migration flag after successful migration', () async {
      await appDataService.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      await migrationService.migrateIfNeeded(prefs);

      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });
  });
}
