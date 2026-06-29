import 'package:sqflite/sqflite.dart';

/// The seam between the read-only services (`DatabaseService`,
/// `AudioMetadata`, `SearchService`, …) and the concrete source of their
/// SQLite databases.
///
/// WHY a named interface: the read-only services were already written to
/// accept an injectable store (see [DatabaseService]'s constructor), but the
/// seam was only the *implicit* interface of the one concrete
/// [BundledDatabaseStore]. A single concrete type behind the seam is a
/// hypothetical seam — nothing varies across it, so nothing tests across it.
/// Naming the seam here turns it into a real one: production satisfies it with
/// [BundledDatabaseStore] (copy a bundled asset to the documents directory,
/// open it read-only), and tests satisfy it with a fake that opens fixtures or
/// reproduces a platform quirk (e.g. the iOS read-only-PRAGMA throw) without
/// touching disk. Callers depend on this type; adapters vary behind it.
abstract interface class DatabaseStore {
  /// Opens the database identified by [assetFileName] and returns a ready
  /// [Database]. Implementations decide where the bytes come from and how the
  /// connection is configured; the contract is only that the returned database
  /// is open and queryable.
  Future<Database> open(String assetFileName);
}
