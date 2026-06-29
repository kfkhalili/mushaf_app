import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/parsing_helpers.dart';
import 'bundled_database_store.dart';
import 'database_store.dart';

/// Read access to the bundled recitation database: per-surah audio URLs and
/// per-ayah playback segment timings.
///
/// WHY a module: these three queries are the only users of the audio database
/// and never join any other database, so they lift cleanly out of the
/// 1600-line DatabaseService. Behind this seam they can be tested against a
/// fixture audio database on their own, and the audio connection has a single
/// owner.
///
/// Throws [DatabaseNotInitializedException] if used before [init].
class AudioMetadata {
  final DatabaseStore _store;
  Database? _audioDb;

  AudioMetadata({DatabaseStore store = const BundledDatabaseStore()})
    : _store = store;

  /// Opens the recitation database (idempotent).
  Future<void> init() async {
    _audioDb ??= await _store.open(audioDbFileName);
  }

  /// Closes the recitation database and releases the handle.
  Future<void> close() async {
    final db = _audioDb;
    _audioDb = null;
    await db?.close();
  }

  Database _requireDb() {
    final db = _audioDb;
    if (db == null) {
      throw DatabaseNotInitializedException(
        "Audio database is not initialized",
      );
    }
    return db;
  }

  /// Audio information (URL, duration) for [surahNumber], or null if absent.
  Future<SurahAudio?> surahAudio(int surahNumber) async {
    final db = _requireDb();
    try {
      final List<Map<String, dynamic>> result = await db.query(
        DbConstants.surahListTable,
        where: '${DbConstants.surahNumberCol} = ?',
        whereArgs: [surahNumber.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) return null;

      final row = result.first;
      // Nullable cast + null check — database data may be corrupt.
      final String? audioUrl = row[DbConstants.audioUrlCol] as String?;
      if (audioUrl == null) {
        throw DatabaseNotFoundException(
          "Surah audio URL not found for surah $surahNumber",
        );
      }
      return SurahAudio(
        surahNumber: parseInt(row[DbConstants.surahNumberCol]),
        audioUrl: audioUrl,
        duration: parseInt(row[DbConstants.durationCol]),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching surah audio for $surahNumber: $e");
      }
      return null;
    }
  }

  /// Segment timings for a single ayah, or null if absent.
  Future<AyahSegment?> ayahSegment(int surahNumber, int ayahNumber) async {
    final db = _requireDb();
    try {
      final List<Map<String, dynamic>> result = await db.query(
        DbConstants.segmentsTable,
        where:
            '${DbConstants.surahNumberCol} = ? AND ${DbConstants.audioAyahNumberCol} = ?',
        whereArgs: [surahNumber.toString(), ayahNumber.toString()],
        limit: QueryLimits.singleResult,
      );

      if (result.isEmpty) return null;

      final row = result.first;
      // Nullable cast + null check — database data may be corrupt.
      final String? segments = row[DbConstants.segmentsCol] as String?;
      if (segments == null) {
        throw DatabaseNotFoundException(
          "Ayah segment data not found for $surahNumber:$ayahNumber",
        );
      }
      return AyahSegment(
        surahNumber: parseInt(row[DbConstants.surahNumberCol]),
        ayahNumber: parseInt(row[DbConstants.audioAyahNumberCol]),
        durationSec: parseInt(row[DbConstants.durationSecCol]),
        timestampFrom: parseInt(row[DbConstants.timestampFromCol]),
        timestampTo: parseInt(row[DbConstants.timestampToCol]),
        segments: segments,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "Error fetching ayah segment for $surahNumber:$ayahNumber: $e",
        );
      }
      return null;
    }
  }

  /// All ayah segments for [surahNumber], ordered by ayah number; rows with
  /// corrupt segment data are skipped.
  Future<List<AyahSegment>> surahSegments(int surahNumber) async {
    final db = _requireDb();
    try {
      final List<Map<String, dynamic>> results = await db.query(
        DbConstants.segmentsTable,
        where: '${DbConstants.surahNumberCol} = ?',
        whereArgs: [surahNumber.toString()],
        orderBy: '${DbConstants.audioAyahNumberCol} ASC',
      );

      return results
          .map((row) {
            // Nullable cast + null check — database data may be corrupt.
            final String? segments = row[DbConstants.segmentsCol] as String?;
            if (segments == null) {
              if (kDebugMode) {
                debugPrint(
                  'Missing segments data for surah ${row[DbConstants.surahNumberCol]}:${row[DbConstants.audioAyahNumberCol]}',
                );
              }
              return null;
            }
            return AyahSegment(
              surahNumber: parseInt(row[DbConstants.surahNumberCol]),
              ayahNumber: parseInt(row[DbConstants.audioAyahNumberCol]),
              durationSec: parseInt(row[DbConstants.durationSecCol]),
              timestampFrom: parseInt(row[DbConstants.timestampFromCol]),
              timestampTo: parseInt(row[DbConstants.timestampToCol]),
              segments: segments,
            );
          })
          .whereType<AyahSegment>()
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching surah segments for $surahNumber: $e");
      }
      return [];
    }
  }
}
