import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('memorizationIconFlashProvider', () {
    test('initializes to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(memorizationIconFlashProvider), 0);
    });

    test('pulse increments the counter by one', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memorizationIconFlashProvider.notifier);
      notifier.pulse();
      notifier.pulse();

      expect(container.read(memorizationIconFlashProvider), 2);
    });

    test('flash emits one pulse per requested time', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memorizationIconFlashProvider.notifier);
      await notifier.flash(times: 3, interval: Duration.zero);

      expect(container.read(memorizationIconFlashProvider), 3);
    });
  });
}
