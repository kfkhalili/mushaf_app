import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'app_data_service.dart';

/// WHY: Migration service to consolidate data from separate databases
/// (bookmarks.db, reading_progress.db) into unified app_data.db.
/// Runs once on first use of the unified database.
class MigrationService {
  final AppDataService _appDataService;

  MigrationService(this._appDataService);

  /// WHY: Checks if migration is needed and runs it if necessary.
  /// Uses SharedPreferences flag to prevent duplicate migrations.
  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('app_data_migrated_v1') ?? false;

    if (migrated) return;

    await _appDataService.ensureInitialized();
    final newDb = _appDataService.database;

    try {
      // WHY: Wrap migration in transaction for atomicity
      // If any part fails, all changes are rolled back
      await newDb.transaction((txn) async {
        // Migrate bookmarks from bookmarks.db
        await _migrateBookmarksWithTxn(txn);

        // Migrate reading sessions from reading_progress.db
        await _migrateReadingSessionsWithTxn(txn);
      });

      // WHY: Mark migration as complete only after successful transaction
      await prefs.setBool('app_data_migrated_v1', true);
    } catch (e) {
      // WHY: If migration fails, log error but don't prevent app from running
      // User can try again later or continue with fresh data
      // ignore: avoid_print
      debugPrint('Migration failed: $e');
      // Don't set flag, so migration can be retried
    }
  }

  /// WHY: Migrates bookmarks within a transaction.
  /// Used by migration transaction to ensure atomicity.
  Future<void> _migrateBookmarksWithTxn(Transaction txn) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final oldDbPath = p.join(documentsDirectory.path, 'bookmarks.db');

    try {
      final oldDb = await openDatabase(oldDbPath, readOnly: true);

      try {
        final bookmarks = await oldDb.query(DbConstants.bookmarksTable);

        // WHY: Use batch insert within transaction for efficiency
        final batch = txn.batch();
        for (final bookmark in bookmarks) {
          batch.insert(
            DbConstants.bookmarksTable,
            bookmark,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);

        await oldDb.close();
      } catch (e) {
        await oldDb.close();
        // WHY: If old database is corrupted or table doesn't exist, skip migration
        // ignore: avoid_print
        debugPrint('Bookmarks migration skipped: $e');
      }
    } catch (e) {
      // WHY: If old database doesn't exist (fresh install), skip migration
      // This is expected for new users
    }
  }

  /// WHY: Migrates reading sessions within a transaction.
  /// Used by migration transaction to ensure atomicity.
  Future<void> _migrateReadingSessionsWithTxn(Transaction txn) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final oldDbPath = p.join(documentsDirectory.path, 'reading_progress.db');

    try {
      final oldDb = await openDatabase(oldDbPath, readOnly: true);

      try {
        final sessions = await oldDb.query(DbConstants.readingSessionsTable);

        // WHY: Use batch insert within transaction for efficiency
        final batch = txn.batch();
        for (final session in sessions) {
          batch.insert(
            DbConstants.readingSessionsTable,
            session,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);

        await oldDb.close();
      } catch (e) {
        await oldDb.close();
        // WHY: If old database is corrupted or table doesn't exist, skip migration
        // ignore: avoid_print
        debugPrint('Reading sessions migration skipped: $e');
      }
    } catch (e) {
      // WHY: If old database doesn't exist (fresh install), skip migration
      // This is expected for new users
    }
  }
}
