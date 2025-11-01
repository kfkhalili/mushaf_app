import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  group('Page Provider Tests', () {
    test('CurrentPage provider initializes to 1', () {
      final container = ProviderContainer();
      final page = container.read(currentPageProvider);
      expect(page, 1);
      container.dispose();
    });

    test('setPage updates current page', () {
      final container = ProviderContainer();

      // Initial state
      expect(container.read(currentPageProvider), 1);

      // Update page
      container.read(currentPageProvider.notifier).setPage(5);
      expect(container.read(currentPageProvider), 5);

      // Update again
      container.read(currentPageProvider.notifier).setPage(302);
      expect(container.read(currentPageProvider), 302);

      container.dispose();
    });

    test('setPage handles edge cases', () {
      final container = ProviderContainer();

      // Valid page numbers
      container.read(currentPageProvider.notifier).setPage(1);
      expect(container.read(currentPageProvider), 1);

      container.read(currentPageProvider.notifier).setPage(604);
      expect(container.read(currentPageProvider), 604);

      container.dispose();
    });
  });

  group('SelectionTabIndex Provider Tests', () {
    test('SelectionTabIndex initializes to 0 (Surah tab)', () {
      final container = ProviderContainer();
      final tabIndex = container.read(selectionTabIndexProvider);
      expect(tabIndex, 0);
      container.dispose();
    });

    test('setTabIndex updates tab index', () {
      final container = ProviderContainer();

      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      expect(container.read(selectionTabIndexProvider), 1);

      container.read(selectionTabIndexProvider.notifier).setTabIndex(2);
      expect(container.read(selectionTabIndexProvider), 2);

      container.dispose();
    });

    test('setTabIndex clamps invalid indices', () {
      final container = ProviderContainer();
      final notifier = container.read(selectionTabIndexProvider.notifier);

      // Should clamp negative values
      notifier.setTabIndex(-1);
      expect(container.read(selectionTabIndexProvider), 0);

      // Should clamp values > 2
      notifier.setTabIndex(5);
      expect(container.read(selectionTabIndexProvider), 0);

      container.dispose();
    });
  });

  group('MushafLayoutSetting Provider Tests', () {
    test('MushafLayoutSetting initializes to uthmani15Lines', () {
      final container = ProviderContainer();
      final layout = container.read(mushafLayoutSettingProvider);
      expect(layout, MushafLayout.uthmani15Lines);
      container.dispose();
    });

    test('setLayout updates layout setting', () {
      final container = ProviderContainer();

      container
          .read(mushafLayoutSettingProvider.notifier)
          .setLayout(MushafLayout.indopak13Lines);
      expect(
        container.read(mushafLayoutSettingProvider),
        MushafLayout.indopak13Lines,
      );

      container.dispose();
    });
  });
}
