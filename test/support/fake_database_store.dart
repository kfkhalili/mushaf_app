import 'package:mushaf_app/exceptions/database_exceptions.dart';
import 'package:mushaf_app/services/database_store.dart';
import 'package:sqflite/sqflite.dart';

/// A [DatabaseStore] for tests that delegates each `open` call to a
/// caller-supplied function.
///
/// This is the second adapter behind the [DatabaseStore] seam (the production
/// adapter is `BundledDatabaseStore`). Its existence is what turns the seam
/// from hypothetical into real: a test decides what each `open(assetFileName)`
/// returns — a fixture database, an in-memory database, or a connection that
/// reproduces a platform quirk — without copying bundled assets to disk.
///
/// ```dart
/// final store = FakeDatabaseStore((asset) async => myInMemoryDb);
/// final service = DatabaseService(store: store);
/// ```
class FakeDatabaseStore implements DatabaseStore {
  final Future<Database> Function(String assetFileName) _opener;

  /// Records every asset name passed to [open], in call order, so a test can
  /// assert which databases a service tried to open.
  final List<String> openedAssets = <String>[];

  FakeDatabaseStore(this._opener);

  @override
  Future<Database> open(String assetFileName) {
    openedAssets.add(assetFileName);
    return _opener(assetFileName);
  }
}

/// A [DatabaseStore] whose every `open` throws [DatabaseConnectionException],
/// simulating an adapter that cannot reach its data (a corrupt asset, a denied
/// path, or — on iOS — an open that fails where the FFI backend used in tests
/// would have succeeded). Lets a test assert that a read-only service surfaces
/// the failure instead of crashing on a null database.
class ThrowingDatabaseStore implements DatabaseStore {
  final String message;

  const ThrowingDatabaseStore([this.message = 'simulated open failure']);

  @override
  Future<Database> open(String assetFileName) {
    throw DatabaseConnectionException("$message: '$assetFileName'");
  }
}
