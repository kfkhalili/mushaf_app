import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/mushaf_screen.dart';

/// Converts Western Arabic numerals (1, 2, 3) to Eastern Arabic numerals (١, ٢, ٣).
String convertToEasternArabicNumerals(String input) {
  const western = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = <String>['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String result = input; // Work on a mutable copy
  for (int i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}

/// Navigates to the MushafScreen, initializing it to the specified page.
///
/// WHY: This helper centralizes the navigation logic used by all
/// list views (Surah, Juz, Page). It handles clearing the
/// 'last_page' preference before pushing the new screen.
Future<void> navigateToMushafPage(BuildContext context, int pageNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('last_page');

  // WHY: Check context.mounted *after* the async gap.
  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MushafScreen(initialPage: pageNumber),
    ),
  );
}
