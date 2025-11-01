import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/utils/ui_signals.dart';

void main() {
  group('memorizationIconFlashTick', () {
    test('initializes to zero', () {
      expect(memorizationIconFlashTick.value, 0);
    });

    test('can be incremented', () {
      final initialValue = memorizationIconFlashTick.value;
      memorizationIconFlashTick.value = initialValue + 1;
      expect(memorizationIconFlashTick.value, greaterThan(initialValue));
    });
  });

  group('flashMemorizationIcon', () {
    test('flashes icon specified number of times', () async {
      final initialValue = memorizationIconFlashTick.value;
      await flashMemorizationIcon(
        times: 3,
        interval: const Duration(milliseconds: 10),
      );
      expect(memorizationIconFlashTick.value, greaterThan(initialValue));
    });

    test('uses default interval when not specified', () async {
      final initialValue = memorizationIconFlashTick.value;
      await flashMemorizationIcon(times: 2);
      expect(memorizationIconFlashTick.value, greaterThan(initialValue));
    });

    test('handles single flash', () async {
      final initialValue = memorizationIconFlashTick.value;
      await flashMemorizationIcon(times: 1);
      expect(memorizationIconFlashTick.value, greaterThan(initialValue));
    });
  });
}
