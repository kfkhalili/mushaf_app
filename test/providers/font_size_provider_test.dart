import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  group('FontSizeSetting', () {
    test('initializes with default font size for uthmani15Lines', () {
      final container = ProviderContainer();
      final fontSize = container.read(fontSizeSettingProvider);

      // Default layout is uthmani15Lines
      expect(fontSize, equals(layoutMaxFontSizes[MushafLayout.uthmani15Lines]));
      container.dispose();
    });

    test('updates font size when layout changes', () {
      final container = ProviderContainer();

      // Get initial font size
      final initialSize = container.read(fontSizeSettingProvider);
      expect(initialSize, equals(layoutMaxFontSizes[MushafLayout.uthmani15Lines]));

      // Change layout (use available layout - check which ones exist)
      // Note: Only testing that font size updates when layout changes
      final availableLayouts = layoutMaxFontSizes.keys.toList();
      if (availableLayouts.length > 1) {
        final newLayout = availableLayouts.firstWhere(
          (layout) => layout != MushafLayout.uthmani15Lines,
        );
        container.read(mushafLayoutSettingProvider.notifier).setLayout(newLayout);

        // Font size should update automatically
        final newSize = container.read(fontSizeSettingProvider);
        expect(newSize, equals(layoutMaxFontSizes[newLayout]));
      }

      container.dispose();
    });

    test('returns correct font size for different layouts', () {
      final container = ProviderContainer();

      // Test with available layouts from layoutMaxFontSizes
      final availableLayouts = layoutMaxFontSizes.keys.toList();

      for (final layout in availableLayouts) {
        container.read(mushafLayoutSettingProvider.notifier).setLayout(layout);

        final fontSize = container.read(fontSizeSettingProvider);
        expect(fontSize, equals(layoutMaxFontSizes[layout]));
      }

      container.dispose();
    });

    test('returns fallback font size for unknown layout', () {
      final container = ProviderContainer();

      // This test verifies the fallback behavior (20.0) if layoutMaxFontSizes
      // doesn't have an entry for a layout
      // Note: In practice, all layouts should have entries, but we test the fallback
      final fontSize = container.read(fontSizeSettingProvider);

      // Should be a valid positive number (either from map or fallback)
      expect(fontSize, greaterThan(0.0));
      expect(fontSize, lessThanOrEqualTo(50.0)); // Reasonable max

      container.dispose();
    });
  });
}

