import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart'; // Import theme provider
import 'themes.dart'; // Import themes

Future<void> main() async {
  // WHY: Ensure bindings are initialized before async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // WHY: Read the saved theme from storage before the app starts.
  final prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme_mode') ?? 'system';
  final AppThemeMode initialTheme = AppThemeMode.values.firstWhere(
    (e) => e.name == savedTheme,
    orElse: () => AppThemeMode.system,
  );

  runApp(
    ProviderScope(
      // WHY: We override the themeProvider's default state with the one
      // we loaded from SharedPreferences.
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialTheme)),
      ],
      child: const MushafApp(),
    ),
  );
}

// WHY: Convert to a ConsumerWidget to watch the theme provider.
class MushafApp extends ConsumerWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state of the theme provider.
    final AppThemeMode currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,

      // WHY: Set the light and dark themes.
      theme: lightTheme,
      darkTheme: darkTheme,

      // WHY: Determine the active theme mode. If it's Sepia, we manually
      // override the theme. Otherwise, we use Flutter's built-in handling
      // for light, dark, and system.
      themeMode: currentThemeMode == AppThemeMode.sepia
          ? ThemeMode
                .light // Use light mode as a base for Sepia
          : currentThemeMode == AppThemeMode.light
          ? ThemeMode.light
          : currentThemeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.system,

      // If the theme is Sepia, we provide the sepiaTheme data.
      builder: (context, child) {
        if (currentThemeMode == AppThemeMode.sepia) {
          return Theme(data: sepiaTheme, child: child!);
        }
        return child!;
      },

      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: SplashScreen(),
      ),
    );
  }
}
