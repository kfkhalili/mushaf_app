import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WHY: This import is required to use SystemUiOverlayStyle.

// Light Theme (Current Theme)
final lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
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
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white70),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);

// Sepia Theme
final sepiaTheme = ThemeData(
  primarySwatch: Colors.brown,
  brightness: Brightness.light,
  // A warm, parchment-like background color.
  scaffoldBackgroundColor: const Color(0xFFF1E8D9),
  appBarTheme: const AppBarTheme(
    foregroundColor: Color(0xFF5B4636), // A dark brown for text
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF5B4636)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF5B4636)),
    bodyMedium: TextStyle(color: Color(0xFF5B4636)),
  ),
);
