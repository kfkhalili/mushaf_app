import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for orientation services
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'themes.dart';

Future<void> main() async {
  // WHY: This is required to ensure that the Flutter engine is initialized
  // before we call any platform-specific services like setting orientation.
  WidgetsFlutterBinding.ensureInitialized();

  // WHY: By setting the preferred orientations here, we lock the entire application
  // to portrait mode only. The user will not be able to rotate it to landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read the saved theme from storage before the app starts.
  final prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme_mode') ?? 'system';
  final AppThemeMode initialTheme = AppThemeMode.values.firstWhere(
    (e) => e.name == savedTheme,
    orElse: () => AppThemeMode.system,
  );

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialTheme)),
      ],
      child: const MushafApp(),
    ),
  );
}

class MushafApp extends ConsumerWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: currentThemeMode == AppThemeMode.sepia
          ? ThemeMode.light
          : currentThemeMode == AppThemeMode.light
          ? ThemeMode.light
          : currentThemeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.system,
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
