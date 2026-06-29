import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/constants.dart';
import 'package:mushaf_app/exceptions/database_exceptions.dart';
import 'package:mushaf_app/services/app_data_service.dart';
import 'package:mushaf_app/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

import '../support/harness.dart';

/// Exercises the [DatabaseStore] seam directly: these tests cross the same
/// interface the production services do, but with test adapters behind it. They
/// are the second/third adapters that make the seam real — without them the
/// seam had a single concrete implementation and nothing tested across it.
void main() {
  useDatabaseTestEnv();

  group('DatabaseStore seam (read-only services)', () {
    const layout = MushafLayout.uthmani15Lines;

    test(
      'DatabaseService routes every database open through the seam',
      () async {
        // The fake records each requested asset before failing the open. We only
        // care that the seam is the single funnel for the read-only databases.
        final store = FakeDatabaseStore(
          (asset) async =>
              throw const DatabaseConnectionException('no fixture'),
        );
        final service = DatabaseService(store: store);

        await expectLater(
          service.init(layout: layout),
          throwsA(isA<DatabaseConnectionException>()),
        );

        expect(
          store.openedAssets,
          containsAll(<String>[
            layout.layoutDatabaseFileName,
            layout.scriptDatabaseFileName,
          ]),
          reason:
              'DatabaseService must open its databases via the injected store',
        );
      },
    );

    test(
      'a failing store surfaces as an exception, not a crash on a null db',
      () async {
        final service = DatabaseService(store: const ThrowingDatabaseStore());

        await expectLater(
          service.init(layout: layout),
          throwsA(isA<DatabaseConnectionException>()),
        );
      },
    );
  });

  group('AppDataService in-memory adapter', () {
    test('two in-memory instances do not share state', () async {
      final a = AppDataService(databasePath: inMemoryDatabasePath);
      final b = AppDataService(databasePath: inMemoryDatabasePath);
      addTearDown(() async {
        await a.close();
        await b.close();
      });

      await a.ensureInitialized();
      await b.ensureInitialized();

      await a.database.insert(DbConstants.bookmarksTable, {
        DbConstants.surahNumberCol: 1,
        DbConstants.ayahNumberCol: 1,
        DbConstants.createdAtCol: '2026-01-01T00:00:00.000Z',
      });

      final aRows = await a.database.query(DbConstants.bookmarksTable);
      final bRows = await b.database.query(DbConstants.bookmarksTable);
      expect(aRows, hasLength(1));
      expect(
        bRows,
        isEmpty,
        reason:
            'in-memory adapters are isolated — no shared on-disk app_data.db',
      );
    });
  });
}
