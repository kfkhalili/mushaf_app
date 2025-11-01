import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../memorization/models.dart';
import '../constants.dart';
import 'app_data_service.dart';
import 'memorization_storage.dart';

/// WHY: SQLite implementation of MemorizationStorage interface.
/// Migrates memorization sessions from in-memory storage to persistent SQLite storage.
/// This ensures memorization progress persists across app restarts.
class SqliteMemorizationStorage implements MemorizationStorage {
  final AppDataService _appDataService;

  SqliteMemorizationStorage(this._appDataService);

  @override
  Future<void> saveSession(MemorizationSessionState state) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    // WHY: Serialize AyahWindowState to JSON for storage
    final windowJson = jsonEncode({
      'ayahIndices': state.window.ayahIndices,
      'opacities': state.window.opacities,
      'tapsSinceReveal': state.window.tapsSinceReveal,
    });

    await db.insert(
      DbConstants.memorizationSessionsTable,
      {
        DbConstants.pageNumberCol: state.pageNumber,
        DbConstants.firstAyahIndexCol: state.window.ayahIndices.isNotEmpty
            ? state.window.ayahIndices.first
            : 0,
        DbConstants.lastAyahIndexShownCol: state.lastAyahIndexShown,
        DbConstants.passCountCol: state.passCount,
        DbConstants.windowDataCol: windowJson,
        DbConstants.lastUpdatedAtCol: state.lastUpdatedAt.toIso8601String(),
        DbConstants.createdAtCol: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<MemorizationSessionState?> loadSession(int pageNumber) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    final results = await db.query(
      DbConstants.memorizationSessionsTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;

    try {
      // WHY: Deserialize JSON back to AyahWindowState
      final windowJson =
          jsonDecode(row[DbConstants.windowDataCol] as String)
              as Map<String, dynamic>;

      return MemorizationSessionState(
        pageNumber: row[DbConstants.pageNumberCol] as int,
        window: AyahWindowState(
          ayahIndices: List<int>.from(windowJson['ayahIndices'] as List),
          opacities: List<double>.from(windowJson['opacities'] as List),
          tapsSinceReveal: List<int>.from(
            windowJson['tapsSinceReveal'] as List,
          ),
        ),
        lastAyahIndexShown: row[DbConstants.lastAyahIndexShownCol] as int,
        lastUpdatedAt: DateTime.parse(
          row[DbConstants.lastUpdatedAtCol] as String,
        ),
        passCount: row[DbConstants.passCountCol] as int,
      );
    } catch (e) {
      // WHY: If JSON parsing fails, return null (corrupted data)
      // This allows the user to start fresh
      return null;
    }
  }

  @override
  Future<void> clearSession(int pageNumber) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    await db.delete(
      DbConstants.memorizationSessionsTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber],
    );
  }
}
