import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/mushaf_screen.dart';
import '../models.dart';

/// Converts Western Arabic numerals (1, 2, 3) to Eastern Arabic numerals (١, ٢, ٣).
String convertToEasternArabicNumerals(String input) {
  const western = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = <String>['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  // Functional approach: use splitMapJoin for character replacement
  return input.splitMapJoin(
    RegExp(r'[0-9]'),
    onMatch: (match) {
      final digit = match.group(0)!;
      final index = western.indexOf(digit);
      return eastern[index];
    },
  );
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

/// Pure function: generates ayah key from surah and ayah numbers
String generateAyahKey(int surah, int ayah) {
  return "${surah.toString().padLeft(3, '0')}:${ayah.toString().padLeft(3, '0')}";
}

/// Pure function: extracts all Quran words from page layout
List<Word> extractQuranWordsFromPage(PageLayout layout) {
  return layout.lines
      .where((line) => line.lineType == 'ayah')
      .expand((line) => line.words)
      .where((word) => word.ayahNumber > 0)
      .toList();
}

/// Pure function: groups words by ayah key
Map<String, List<Word>> groupWordsByAyahKey(List<Word> words) {
  return words.fold<Map<String, List<Word>>>({}, (map, word) {
    final key = generateAyahKey(word.surahNumber, word.ayahNumber);
    map.putIfAbsent(key, () => []).add(word);
    return map;
  });
}

/// Formats a DateTime to a relative date string in Arabic
String formatRelativeDate(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final bookmarkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final difference = today.difference(bookmarkDate).inDays;

  if (difference == 0) {
    return 'اليوم';
  } else if (difference == 1) {
    return 'أمس';
  } else if (difference <= 7) {
    return 'منذ ${convertToEasternArabicNumerals(difference.toString())} أيام';
  } else {
    // For dates older than a week, return formatted date
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final day = convertToEasternArabicNumerals(dateTime.day.toString());
    final month = months[dateTime.month - 1];
    return '$day $month';
  }
}
