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
      // Clean up database tables
      try {
        final db = appDataService.database;
        await db.delete(DbConstants.bookmarksTable);
        await db.delete(DbConstants.readingSessionsTable);
        await db.delete(DbConstants.memorizationSessionsTable);
      } catch (e) {
        // Ignore errors if database is already closed
      }

      await appDataService.close();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_data_migrated_v1');
    });

    test('does not migrate if already migrated', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_data_migrated_v1', true);

      await appDataService.ensureInitialized();
      await migrationService.migrateIfNeeded();

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

      // Insert test bookmark
      await oldDb.insert(DbConstants.bookmarksTable, {
        DbConstants.surahNumberCol: testSurah,
        DbConstants.ayahNumberCol: testAyah,
        DbConstants.cachedPageNumberCol: 2,
        DbConstants.createdAtCol: DateTime.now().toIso8601String(),
        DbConstants.noteCol: 'Test note',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await oldDb.close();

      // Clear any existing data in new DB first
      final db = appDataService.database;
      await db.delete(
        DbConstants.bookmarksTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.ayahNumberCol} = ?',
        whereArgs: [testSurah, testAyah],
      );

      // Run migration
      await migrationService.migrateIfNeeded();

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

      final now = DateTime.now();
      await oldDb.insert(DbConstants.readingSessionsTable, {
        DbConstants.sessionDateCol: now.toIso8601String().split('T')[0],
        DbConstants.pageNumberCol: 5,
        DbConstants.timestampCol: now.toIso8601String(),
        DbConstants.durationSecondsCol: 120,
      });

      await oldDb.close();

      // Run migration
      await appDataService.ensureInitialized();
      await migrationService.migrateIfNeeded();

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
      await migrationService.migrateIfNeeded();

      // Migration should complete successfully
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });

    test('sets migration flag after successful migration', () async {
      await appDataService.ensureInitialized();
      await migrationService.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('app_data_migrated_v1'), isTrue);
    });
  });
}
