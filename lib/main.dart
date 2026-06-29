import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for orientation services
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'providers.dart';
import 'themes.dart';

Future<void> main() async {
  // WHY: This is required to ensure that the Flutter engine is initialized
  // before we call any platform-specific services like setting orientation.
  WidgetsFlutterBinding.ensureInitialized();

  // WHY: Portrait-only is a deliberate, current product decision. The reading
  // surface is form-factor-proof (PageFit measures to any box), but the *chrome*
  // (headers, nav, dialogs) is not yet landscape/wide adaptive. Unlocking
  // orientation is gated on that adaptive-chrome work (see WindowSizeClass in
  // utils/responsive.dart) — not a one-line change, so the lock stays until then.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MushafApp()));
}

class MushafApp extends ConsumerWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeMode currentThemeMode = ref.watch(themeProvider);
    final primaryColorValue = ref.watch(primaryColorProvider);

    // WHY: Generate themes dynamically based on selected primary color
    final lightThemeDynamic = buildLightTheme(primaryColorValue);
    final darkThemeDynamic = buildDarkTheme(primaryColorValue);
    final sepiaThemeDynamic = buildSepiaTheme(primaryColorValue);

    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,
      theme: lightThemeDynamic,
      darkTheme: darkThemeDynamic,
      themeMode: currentThemeMode == AppThemeMode.sepia
          ? ThemeMode.light
          : currentThemeMode == AppThemeMode.light
          ? ThemeMode.light
          : currentThemeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.system,
      builder: (context, child) {
        if (currentThemeMode == AppThemeMode.sepia) {
          return Theme(data: sepiaThemeDynamic, child: child!);
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
