import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Define an enum for our theme modes for type safety.
enum AppThemeMode { light, dark, sepia, system }

// 2. Create the Notifier class.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier(super.defaultMode);

  // Method to change the theme and persist the choice.
  Future<void> setTheme(AppThemeMode mode) async {
    // Update the state to notify listeners (like MaterialApp).
    state = mode;
    // Save the choice to the device.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.name);
    } catch (e) {
      // Handle potential errors, e.g., if storage is unavailable.
    }
  }
}

// 3. Define the provider.
// We will initialize its state in main.dart after reading from SharedPreferences.
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  // The initial state here is a fallback. The actual initial state
  // will be set in main.dart by overriding this provider.
  return ThemeNotifier(AppThemeMode.system);
});
