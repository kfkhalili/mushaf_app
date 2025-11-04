import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      limit: QueryLimits.singleResult,
    );

    if (results.isEmpty) return null;

    final row = results.first;

    try {
      // Use nullable cast and check for null
      // WHY: Type safety - database data may be corrupted
      final String? windowDataStr = row[DbConstants.windowDataCol] as String?;
      if (windowDataStr == null) {
        if (kDebugMode) {
          debugPrint('Missing window data in memorization session');
        }
        return null; // Safe default
      }

      // WHY: Deserialize JSON back to AyahWindowState
      final decoded = jsonDecode(windowDataStr);
      if (decoded is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint('Expected Map, got ${decoded.runtimeType}');
        }
        return null; // Safe default
      }
      final windowJson = decoded;

      // Validate required fields before accessing
      // WHY: Defense in depth - validate JSON structure
      if (!windowJson.containsKey('ayahIndices') ||
          !windowJson.containsKey('opacities') ||
          !windowJson.containsKey('tapsSinceReveal')) {
        if (kDebugMode) {
          debugPrint('Missing required fields in window data');
        }
        return null; // Safe default
      }

      // Validate field types
      if (windowJson['ayahIndices'] is! List ||
          windowJson['opacities'] is! List ||
          windowJson['tapsSinceReveal'] is! List) {
        if (kDebugMode) {
          debugPrint('Invalid field types in window data');
        }
        return null; // Safe default
      }

      final int? pageNumber = row[DbConstants.pageNumberCol] as int?;
      final int? lastAyahIndexShown =
          row[DbConstants.lastAyahIndexShownCol] as int?;
      final int? passCount = row[DbConstants.passCountCol] as int?;
      final String? lastUpdatedAtStr =
          row[DbConstants.lastUpdatedAtCol] as String?;

      if (pageNumber == null ||
          lastAyahIndexShown == null ||
          passCount == null ||
          lastUpdatedAtStr == null) {
        if (kDebugMode) {
          debugPrint('Missing required fields in memorization session');
        }
        return null; // Safe default
      }

      // Parse DateTime safely with exception handling
      // WHY: Corrupted database data may contain invalid date formats
      DateTime lastUpdatedAt;
      try {
        lastUpdatedAt = DateTime.parse(lastUpdatedAtStr);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'Invalid date format in memorization session: $lastUpdatedAtStr',
          );
        }
        // Use current date as safe default
        lastUpdatedAt = DateTime.now();
      }

      // Validate and convert list elements before List.from() conversion
      // WHY: Defense in depth - validate individual list elements
      final ayahIndicesRaw = windowJson['ayahIndices'] as List;
      final ayahIndices = ayahIndicesRaw
          .map((e) {
            if (e is int) return e;
            if (e is String) {
              final parsed = int.tryParse(e);
              if (parsed != null) return parsed;
            }
            return null; // Invalid element
          })
          .whereType<int>() // Filter out null values
          .toList();

      final opacitiesRaw = windowJson['opacities'] as List;
      final opacities = opacitiesRaw
          .map((e) {
            if (e is double) return e;
            if (e is int) return e.toDouble();
            if (e is String) {
              final parsed = double.tryParse(e);
              if (parsed != null) return parsed;
            }
            return null; // Invalid element
          })
          .whereType<double>() // Filter out null values
          .toList();

      final tapsSinceRevealRaw = windowJson['tapsSinceReveal'] as List;
      final tapsSinceReveal = tapsSinceRevealRaw
          .map((e) {
            if (e is int) return e;
            if (e is String) {
              final parsed = int.tryParse(e);
              if (parsed != null) return parsed;
            }
            return null; // Invalid element
          })
          .whereType<int>() // Filter out null values
          .toList();

      return MemorizationSessionState(
        pageNumber: pageNumber,
        window: AyahWindowState(
          ayahIndices: ayahIndices,
          opacities: opacities,
          tapsSinceReveal: tapsSinceReveal,
        ),
        lastAyahIndexShown: lastAyahIndexShown,
        lastUpdatedAt: lastUpdatedAt,
        passCount: passCount,
      );
    } catch (e) {
      // WHY: If JSON parsing fails, return null (corrupted data)
      // This allows the user to start fresh
      if (kDebugMode) {
        debugPrint('Error deserializing memorization session: $e');
      }
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
