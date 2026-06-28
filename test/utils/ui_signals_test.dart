import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';

// The global memorization-flash `ValueNotifier` was replaced by
// `memorizationIconFlashProvider`. Its detailed behavior is covered in
// test/providers/memorization_icon_flash_provider_test.dart; this file just
// confirms the migrated signal is reachable and starts at rest.
void main() {
  test('memorization icon flash is provider-backed and starts at 0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(memorizationIconFlashProvider), 0);
  });
}
