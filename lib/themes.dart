import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WHY: This import is required to use SystemUiOverlayStyle.
import 'constants.dart';

// Helper function to create TextTheme with IBMPlexSansArabic font family
TextTheme _textThemeWithIBMPlexSansArabic(Color? defaultColor) {
  const String fontFamily = 'IBMPlexSansArabic';
  return TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, color: defaultColor),
    displayMedium: TextStyle(fontFamily: fontFamily, color: defaultColor),
    displaySmall: TextStyle(fontFamily: fontFamily, color: defaultColor),
    headlineLarge: TextStyle(fontFamily: fontFamily, color: defaultColor),
    headlineMedium: TextStyle(fontFamily: fontFamily, color: defaultColor),
    headlineSmall: TextStyle(fontFamily: fontFamily, color: defaultColor),
    titleLarge: TextStyle(fontFamily: fontFamily, color: defaultColor),
    titleMedium: TextStyle(fontFamily: fontFamily, color: defaultColor),
    titleSmall: TextStyle(fontFamily: fontFamily, color: defaultColor),
    bodyLarge: TextStyle(fontFamily: fontFamily, color: defaultColor),
    bodyMedium: TextStyle(fontFamily: fontFamily, color: defaultColor),
    bodySmall: TextStyle(fontFamily: fontFamily, color: defaultColor),
    labelLarge: TextStyle(fontFamily: fontFamily, color: defaultColor),
    labelMedium: TextStyle(fontFamily: fontFamily, color: defaultColor),
    labelSmall: TextStyle(fontFamily: fontFamily, color: defaultColor),
  );
}

// WHY: Generates light theme dynamically using Material 3 ColorScheme.fromSeed()
// This ensures consistent color palette based on the primary color seed.
// Overrides primary color with exact user-selected color for vibrant colors.
ThemeData buildLightTheme(int primaryColorValue) {
  final seedColor = Color(primaryColorValue);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ).copyWith(primary: seedColor);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'IBMPlexSansArabic',
    textTheme: _textThemeWithIBMPlexSansArabic(null),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.black87,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
}

// WHY: Generates dark theme dynamically using Material 3 ColorScheme.fromSeed()
// This ensures consistent color palette based on the primary color seed.
// Overrides primary color with exact user-selected color for vibrant colors.
ThemeData buildDarkTheme(int primaryColorValue) {
  final seedColor = Color(primaryColorValue);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ).copyWith(primary: seedColor);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'IBMPlexSansArabic',
    textTheme: _textThemeWithIBMPlexSansArabic(Colors.white70),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}

// WHY: Generates sepia theme with custom brown color for warm parchment feel
// Uses Material 3 ColorScheme but keeps sepia-specific background colors.
// Overrides primary color with exact user-selected color for vibrant colors.
ThemeData buildSepiaTheme(int primaryColorValue) {
  // WHY: Use brown as seed for sepia theme unless user customizes
  final seedColor = primaryColorValue == PrimaryColorConstants.defaultColor
      ? Color(PrimaryColorConstants.defaultSepiaColor)
      : Color(primaryColorValue);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ).copyWith(primary: Color(primaryColorValue));

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF1E8D9),
    fontFamily: 'IBMPlexSansArabic',
    textTheme: _textThemeWithIBMPlexSansArabic(const Color(0xFF5B4636)),
    appBarTheme: const AppBarTheme(
      foregroundColor: Color(0xFF5B4636),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF5B4636)),
  );
}

// WHY: Legacy static themes kept for backwards compatibility if needed
// These are now deprecated in favor of dynamic theme builders above.
@Deprecated('Use buildLightTheme() instead')
final lightTheme = buildLightTheme(PrimaryColorConstants.defaultColor);

@Deprecated('Use buildDarkTheme() instead')
final darkTheme = buildDarkTheme(PrimaryColorConstants.defaultColor);

@Deprecated('Use buildSepiaTheme() instead')
final sepiaTheme = buildSepiaTheme(PrimaryColorConstants.defaultSepiaColor);
