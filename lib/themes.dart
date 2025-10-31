import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WHY: This import is required to use SystemUiOverlayStyle.

// Helper function to create TextTheme with Zain font family
TextTheme _textThemeWithZain(Color? defaultColor) {
  const String fontFamily = 'Zain';
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

// Light Theme (Current Theme)
final lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Zain',
  textTheme: _textThemeWithZain(null), // null uses default color
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.black87,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
);

// Dark Theme
final darkTheme = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.dark,
  // Use a dark, off-black for a softer look than pure black.
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'Zain',
  textTheme: _textThemeWithZain(Colors.white70),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
);

// Sepia Theme
final sepiaTheme = ThemeData(
  primarySwatch: Colors.brown,
  brightness: Brightness.light,
  // A warm, parchment-like background color.
  scaffoldBackgroundColor: const Color(0xFFF1E8D9),
  fontFamily: 'Zain',
  textTheme: _textThemeWithZain(const Color(0xFF5B4636)),
  appBarTheme: const AppBarTheme(
    foregroundColor: Color(0xFF5B4636), // A dark brown for text
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF5B4636)),
);
