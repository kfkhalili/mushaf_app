/// Shared test harness for mushaf_app.
///
/// One import (`import '../support/harness.dart';`) brings in the database test
/// environment, the widget pump shell, the settle/await helpers, and the
/// `DatabaseStore` test adapters. See the individual files for the WHY behind
/// each piece.
library;

export 'db_test_env.dart';
export 'fake_database_store.dart';
export 'pump.dart';
