import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'surah_selection_screen.dart';
import 'mushaf_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // WHY: We check for the last page as soon as the splash screen is built.
    _checkLastPage();
  }

  Future<void> _checkLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    // A short delay prevents a jarring flash if the check is too fast.
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if the widget is still mounted before navigating.
    if (!mounted) return;

    final int? lastPage = prefs.getInt('last_page');

    if (lastPage != null && lastPage > 0) {
      // WHY: If a page was saved, we navigate to the MushafScreen directly.
      // However, to ensure the back button on the overlay works, we first
      // replace the splash screen with the SurahSelectionScreen, then push
      // the MushafScreen on top. This creates the correct navigation stack.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SurahSelectionScreen()),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MushafScreen(initialPage: lastPage),
        ),
      );
    } else {
      // WHY: If no page was saved (first launch), we go to the Surah selection screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SurahSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple loading indicator for the splash screen.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
