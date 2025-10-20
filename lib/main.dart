import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/surah_selection_screen.dart'; // Import the new screen

void main() {
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
        fontFamily: 'QPCV2',
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        // The app now starts at the selection screen
        child: SurahSelectionScreen(),
      ),
    );
  }
}
