import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/mushaf_screen.dart'; // Import the screen

void main() {
  // Ensure Flutter bindings are initialized (needed for assets)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MushafApp()));
}

class MushafApp extends StatelessWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // Fallback font family if specific page font fails
        fontFamily: 'QPCV2',
        appBarTheme: const AppBarTheme(
          // Ensure AppBar text is readable
          foregroundColor: Colors.black87,
          // Make status bar icons dark for light background
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        // Use a clean white background
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Directionality(
        // Set the default text direction for the whole app
        textDirection: TextDirection.rtl,
        child: MushafScreen(), // Use the refactored screen
      ),
    );
  }
}
