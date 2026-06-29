import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();
  group('BookmarksNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() async {
      // Wait a bit before disposing to allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));
      container.dispose();
    });

    test('initializes with list', () async {
      // Wait for the provider to initialize properly
      // The provider loads bookmarks from the database asynchronously
      final bookmarks = await container.read(bookmarksProvider.future);
      expect(bookmarks, isA<List>());
      // List may be empty or contain migrated data
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
