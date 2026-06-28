import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/validation_helpers.dart';
import 'bundled_database_store.dart';

/// Service for accessing tafsir (Quranic commentary) data
class TafsirService with InitializationMixin {
  Database? _tafsirDb;

  // WHY: Loads + opens the bundled tafsir database. Injectable so tests can
  // substitute a store that opens fixtures instead of bundled assets.
  final BundledDatabaseStore _store;

  TafsirService({BundledDatabaseStore store = const BundledDatabaseStore()})
    : _store = store;

  @override
  Future<void> doInit() async {
    try {
      _tafsirDb = await _store.open(tafsirDbFileName);

      markInitialized();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('TafsirService initialization failed: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  Future<void> close() async {
    await _tafsirDb?.close();
    _tafsirDb = null;
    resetInitializationState();
  }

  /// Retrieves tafsir text for a specific ayah.
  /// Returns null if no tafsir is found for the ayah.
  Future<String?> getTafsirForAyah(int surahNumber, int ayahNumber) async {
    // Validate input parameters
    validateSurahAyah(surahNumber, ayahNumber);

    await ensureInitialized();
    if (_tafsirDb == null) {
      throw DatabaseNotInitializedException(
        "Tafsir database is not initialized",
      );
    }

    final ayahKey = '$surahNumber:$ayahNumber';

    try {
      final List<Map<String, dynamic>> result = await _tafsirDb!.query(
        'tafsir',
        columns: ['text'],
        where: 'ayah_key = ?',
        whereArgs: [ayahKey],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final String? text = result.first['text'] as String?;
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
      return null; // Return null if not found
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "Error fetching tafsir for ayah $surahNumber:$ayahNumber: $e",
        );
        // TODO: Include stackTrace when implementing crash analytics
        // catch (e, stackTrace) { ... debugPrint(stackTrace.toString()); }
      }
      return null; // Return null on error
    }
  }
}
