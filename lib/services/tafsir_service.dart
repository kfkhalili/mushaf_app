import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/initialization_mixin.dart';
import '../utils/validation_helpers.dart';

/// Service for accessing tafsir (Quranic commentary) data
class TafsirService with InitializationMixin {
  Database? _tafsirDb;

  @override
  Future<void> doInit() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      const dbAssetPath = 'assets/db';

      _tafsirDb = await _initDb(
        documentsDirectory,
        dbAssetPath,
        tafsirDbFileName,
      );

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

  /// Initializes a database by copying from assets if not already present.
  /// WHY: Reuse pattern from OntologyService for consistency.
  Future<Database> _initDb(
    Directory documentsDirectory,
    String assetPath,
    String assetFileName,
  ) async {
    final destinationPath = p.join(documentsDirectory.path, assetFileName);

    await _copyDatabaseIfNeeded(
      assetFileName: assetFileName,
      destinationPath: destinationPath,
    );

    try {
      final db = await openDatabase(
        destinationPath,
        readOnly: true,
        singleInstance: true,
      );

      return db;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error opening tafsir database: $e\n$stackTrace');
      }
      throw DatabaseConnectionException(
        "Error opening database '$assetFileName'",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Copies database from assets to documents directory if it doesn't exist.
  /// WHY: Reuse pattern from OntologyService for consistency.
  Future<void> _copyDatabaseIfNeeded({
    required String assetFileName,
    required String destinationPath,
  }) async {
    // Validate database file name against whitelist
    final allowedDbNames = [tafsirDbFileName];
    try {
      validateDatabaseFileName(assetFileName, allowedDbNames);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException("Invalid database file name: $e");
    }

    final dbFile = File(destinationPath);

    // Validate path to prevent path traversal
    final documentsDirectory = await getApplicationDocumentsDirectory();
    try {
      validateFilePath(destinationPath, documentsDirectory.path);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException("Path traversal detected: $e");
    }

    // WHY: Avoid recopying if the database already exists.
    if (await dbFile.exists()) {
      return;
    }
    try {
      if (kDebugMode) {
        debugPrint('Copying tafsir database from assets: $assetFileName');
      }
      // WHY: Load the database from assets and write it to the device's documents directory.
      final assetPath = p.join('assets/db', assetFileName);
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.parent.create(recursive: true); // Ensure directory exists
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error copying database: $e\n$stackTrace');
      }
      throw DatabaseConnectionException(
        "Error copying database '$assetFileName' from assets",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
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
