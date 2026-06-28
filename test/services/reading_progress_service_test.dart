import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_app/services/reading_progress_service.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // WHY: Create a unique temp directory per test file execution to avoid
  // database locking when multiple test files run in parallel
  late Directory testTempDir;

  setUpAll(() async {
    // Set up mock SharedPreferences for migration service
    SharedPreferences.setMockInitialValues({});

    // Initialize sqflite for testing (required for non-device tests)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // WHY: Create a unique temporary directory for this test file execution
    // This prevents database locking when multiple test files run in parallel
    testTempDir = await Directory.systemTemp.createTemp(
      'reading_progress_test_',
    );

    // Mock path_provider platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              // WHY: Return unique temp directory per test file to prevent conflicts
              return testTempDir.path;
            }
            throw UnimplementedError();
          },
        );
  });

  tearDownAll(() async {
    // Clear mock handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );

    // WHY: Clean up unique temp directory after all tests complete
    try {
      await testTempDir.delete(recursive: true);
    } catch (e) {
      // Ignore cleanup errors if directory is already deleted
    }
  });

  group('ReadingProgressService', () {
    late SqliteReadingProgressService service;
    late AppDataService appDataService;

    setUp(() {
      appDataService = AppDataService();
      service = SqliteReadingProgressService(appDataService);
    });

    tearDown(() async {
      // WHY: Graceful cleanup using transactions for atomic operations
      // Ensures all pending database operations complete before closing
      try {
        final db = appDataService.database;

        // WHY: Wrap cleanup in transaction for atomicity and better error handling
        // This ensures all cleanup operations complete successfully or rollback together
        await db.transaction((txn) async {
          // WHY: Check if table exists before attempting cleanup
          final tables = await txn.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
            [DbConstants.readingSessionsTable],
          );

          if (tables.isNotEmpty) {
            // WHY: Delete all rows atomically within transaction
            await txn.delete(DbConstants.readingSessionsTable);
          }
        });
      } catch (e) {
        // Ignore cleanup errors if database is already closed or table doesn't exist
      }

      // WHY: Clear cached statistics after data cleanup
      // Note: clearAllData() also clears the table, but this ensures cache is cleared
      try {
        await service.clearAllData();
      } catch (e) {
        // Ignore if already cleaned up or database is closed
      }

      // WHY: Ensure connection is fully closed and all transactions are committed
      // Wait for any pending operations to complete before closing
      await appDataService.close();

      // WHY: Small delay to ensure connection is fully closed and files are released
      // This prevents race conditions when tests run in quick succession
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('recordPageView records valid page numbers', () async {
      // Clear any existing data first
      await service.clearAllData();

      await service.recordPageView(1);
      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 1);
    });

    test(
      'recordPageView throws ArgumentError for invalid page numbers',
      () async {
        // WHY: This service is constructed without a DatabaseService, so only
        // the layout-independent bounds apply. Page counts are layout-specific
        // (Uthmani 604, Indopak 849, Indopak 9-line 1890), so 605 is no longer
        // universally invalid; only <1 and beyond the absolute ceiling are.
        expect(() => service.recordPageView(0), throwsA(isA<ArgumentError>()));
        expect(
          () => service.recordPageView(maxSupportedPages + 1),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('getStatistics returns empty statistics initially', () async {
      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 0);
      expect(stats.totalReadingDays, 0);
      expect(stats.currentStreak, 0);
    });

    test('getPagesReadToday returns 0 initially', () async {
      final pagesToday = await service.getPagesReadToday();
      expect(pagesToday, 0);
    });

    test('getCurrentStreak returns 0 initially', () async {
      final streak = await service.getCurrentStreak();
      expect(streak, 0);
    });

    test('getStatistics calculates total pages correctly', () async {
      await service.recordPageView(1);
      await service.recordPageView(2);
      await service.recordPageView(3);

      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 3);
    });

    test('clearAllData removes all data', () async {
      await service.recordPageView(1);
      await service.clearAllData();

      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 0);
    });
  });
}
