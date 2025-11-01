import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_app/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('themeProvider initializes to system mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeProvider), AppThemeMode.system);
    });

    test('setTheme updates theme mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
      expect(container.read(themeProvider), AppThemeMode.dark);
    });

    test('setTheme persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeProvider.notifier).setTheme(AppThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('setTheme handles all theme modes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final mode in AppThemeMode.values) {
        await container.read(themeProvider.notifier).setTheme(mode);
        expect(container.read(themeProvider), mode);
      }
    });
  });
}
