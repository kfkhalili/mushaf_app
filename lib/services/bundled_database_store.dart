import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/validation_helpers.dart';
import 'database_store.dart';

/// Loads the read-only SQLite databases shipped under `assets/db/`.
///
/// This is the single seam between the read-only services
/// (`DatabaseService`, `SearchService`, `TafsirService`, `OntologyService`)
/// and the `rootBundle` + `sqflite` primitives. Each [open] call copies the
/// requested asset into the app documents directory when needed and opens it
/// read-only.
///
/// WHY a module: the asset-copy + open logic was previously duplicated across
/// four services, and the "when to recopy" rule had already drifted between
/// them. Concentrating it here gives one place to fix copy quirks. It is the
/// production adapter for the [DatabaseStore] seam; tests inject a different
/// [DatabaseStore] (a fixture opener or a platform-quirk simulator) to exercise
/// the read-only services without bundled assets.
///
/// Throws [DatabaseConnectionException] when the asset name is not on the
/// [bundledDatabaseFileNames] whitelist, when the destination escapes the
/// documents directory, or when the copy/open fails.
class BundledDatabaseStore implements DatabaseStore {
  const BundledDatabaseStore();

  static const String _assetDir = 'assets/db';

  /// Ensures [assetFileName] is present in the documents directory (copying it
  /// from bundled assets when needed) and opens it read-only.
  ///
  /// [assetFileName] must be one of [bundledDatabaseFileNames].
  @override
  Future<Database> open(String assetFileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final destinationPath = p.join(documentsDirectory.path, assetFileName);

    await _copyIfNeeded(
      assetFileName: assetFileName,
      destinationPath: destinationPath,
      documentsDirPath: documentsDirectory.path,
    );

    return _openReadOnly(assetFileName, destinationPath);
  }

  Future<void> _copyIfNeeded({
    required String assetFileName,
    required String destinationPath,
    required String documentsDirPath,
  }) async {
    // Validate the asset name against the bundled-DB whitelist.
    try {
      validateDatabaseFileName(assetFileName, bundledDatabaseFileNames);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException('Invalid database file name: $e');
    }

    // Validate the destination path to prevent path traversal.
    try {
      validateFilePath(destinationPath, documentsDirPath);
    } on ArgumentError catch (e) {
      throw DatabaseConnectionException('Path traversal detected: $e');
    }

    // WHY: In debug, always recopy so database edits made during development
    // are picked up. In release, copy only once (when absent) for performance.
    final dbFile = File(destinationPath);
    final shouldRecopy = kDebugMode || !await dbFile.exists();
    if (!shouldRecopy) return;

    try {
      final ByteData data = await rootBundle.load(
        p.join(_assetDir, assetFileName),
      );
      final List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await dbFile.parent.create(recursive: true); // Ensure directory exists.
      await dbFile.writeAsBytes(bytes, flush: true);
    } catch (e, stackTrace) {
      throw DatabaseConnectionException(
        "Error copying database '$assetFileName' from assets",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Database> _openReadOnly(String assetFileName, String dbPath) async {
    try {
      final db = await openDatabase(
        dbPath,
        readOnly: true,
        singleInstance:
            true, // WHY: Reuse the connection for better performance.
      );

      // WHY: busy_timeout softens contention under concurrent access. On iOS
      // (SqfliteDarwinDatabase) executing PRAGMA on a read-only database throws
      // even though it is not an error; the FFI backend used in tests allows
      // it. Wrap in try/catch so the platform difference is harmless — the
      // database is fully functional without the setting.
      try {
        await db.execute('PRAGMA busy_timeout=5000'); // 5 second timeout.
      } catch (_) {
        // Ignore PRAGMA failures on read-only databases (iOS quirk).
      }

      return db;
    } catch (e, stackTrace) {
      throw DatabaseConnectionException(
        "Error opening database '$assetFileName'",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
