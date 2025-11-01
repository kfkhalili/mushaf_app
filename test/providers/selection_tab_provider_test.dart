import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('SelectionTabIndex', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with 0 (Surah tab)', () {
      final tabIndex = container.read(selectionTabIndexProvider);
      expect(tabIndex, 0);
    });

    test('setTabIndex updates state with valid index 0', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(0);
      expect(container.read(selectionTabIndexProvider), 0);
    });

    test('setTabIndex updates state with valid index 1', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      expect(container.read(selectionTabIndexProvider), 1);
    });

    test('setTabIndex updates state with valid index 2', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(2);
      expect(container.read(selectionTabIndexProvider), 2);
    });

    test('setTabIndex ignores negative index', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      container.read(selectionTabIndexProvider.notifier).setTabIndex(-1);
      // Should remain at 1
      expect(container.read(selectionTabIndexProvider), 1);
    });

    test('setTabIndex ignores index greater than 2', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      container.read(selectionTabIndexProvider.notifier).setTabIndex(5);
      // Should remain at 1
      expect(container.read(selectionTabIndexProvider), 1);
    });

    test('setTabIndex allows sequential changes', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(0);
      expect(container.read(selectionTabIndexProvider), 0);

      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      expect(container.read(selectionTabIndexProvider), 1);

      container.read(selectionTabIndexProvider.notifier).setTabIndex(2);
      expect(container.read(selectionTabIndexProvider), 2);
    });
  });
}
