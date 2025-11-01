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
    onNonMatch: (nonMatch) => nonMatch,
  );
}

/// Navigates to the MushafScreen, initializing it to the specified page.
///
/// WHY: This helper centralizes the navigation logic used by all
/// list views (Surah, Juz, Page). It handles clearing the
/// 'last_page' preference before pushing the new screen.
///
/// Takes NavigatorState to avoid using BuildContext across async gaps.
Future<void> navigateToMushafPage(
  NavigatorState navigator,
  bool isMounted,
  int pageNumber,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('last_page');

  // WHY: Check mounted state *after* the async gap.
  if (!isMounted) return;

  navigator.push(
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
      'ديسمبر',
    ];
    final day = convertToEasternArabicNumerals(dateTime.day.toString());
    final month = months[dateTime.month - 1];
    return '$day $month';
  }
}

/// Formats pages read today with proper Arabic grammar.
///
/// Rules:
/// - 0: "لا صفحات اليوم"
/// - 1: "صفحة واحدة اليوم"
/// - 2: "صفحتان اليوم" (dual form)
/// - 3-10: "٣ صفحات اليوم" (plural form)
/// - 11+: "صفحة اليوم" (singular form)
String formatPagesToday(int count) {
  if (count == 0) {
    return 'لا صفحات اليوم';
  } else if (count == 1) {
    return 'صفحة واحدة اليوم';
  } else if (count == 2) {
    return 'صفحتان اليوم';
  } else if (count >= 3 && count <= 10) {
    return '${convertToEasternArabicNumerals(count.toString())} صفحات اليوم';
  } else {
    // 11 and above use singular form
    return '${convertToEasternArabicNumerals(count.toString())} صفحة اليوم';
  }
}

/// Formats a count of pages with proper Arabic grammar (without "اليوم").
///
/// Rules:
/// - 0: "لا صفحات"
/// - 1: "صفحة واحدة"
/// - 2: "صفحتان" (dual form)
/// - 3-10: "٣ صفحات" (plural form)
/// - 11+: "١١ صفحة" (singular form)
String formatPages(int count) {
  if (count == 0) {
    return 'لا صفحات';
  } else if (count == 1) {
    return 'صفحة واحدة';
  } else if (count == 2) {
    return 'صفحتان';
  } else if (count >= 3 && count <= 10) {
    return '${convertToEasternArabicNumerals(count.toString())} صفحات';
  } else {
    // 11 and above use singular form
    return '${convertToEasternArabicNumerals(count.toString())} صفحة';
  }
}

/// Formats a count of days with proper Arabic grammar.
///
/// Rules:
/// - 1: "يوم واحد" or "يوم" (singular)
/// - 2: "يومان" (dual form)
/// - 3-10: "٣ أيام" (plural form)
/// - 11+: "١١ يوما" (singular form with accusative ending)
String formatDays(int count) {
  if (count == 1) {
    return 'يوم واحد';
  } else if (count == 2) {
    return 'يومان';
  } else if (count >= 3 && count <= 10) {
    return '${convertToEasternArabicNumerals(count.toString())} أيام';
  } else {
    // 11 and above use singular form with accusative ending
    return '${convertToEasternArabicNumerals(count.toString())} يوما';
  }
}

/// Formats pages progress (e.g., "X / 604 صفحة").
/// Handles proper grammar for the read count.
/// The total is always formatted with "صفحة" since it's 604 (11+).
String formatPagesProgress(int read, int total) {
  final readFormatted = formatPages(read);
  final totalNum = convertToEasternArabicNumerals(total.toString());
  return '$readFormatted / $totalNum صفحة';
}

/// Formats pages per day rate (e.g., "5 صفحات/يوم" or "11 صفحة/يوم").
/// Uses proper grammar based on the count.
String formatPagesPerDay(int count) {
  if (count == 0) {
    return 'لا صفحات/يوم';
  } else if (count == 1) {
    return 'صفحة واحدة/يوم';
  } else if (count == 2) {
    return 'صفحتان/يوم';
  } else if (count >= 3 && count <= 10) {
    return '${convertToEasternArabicNumerals(count.toString())} صفحات/يوم';
  } else {
    // 11 and above use singular form
    return '${convertToEasternArabicNumerals(count.toString())} صفحة/يوم';
  }
}

/// Formats days out of a total (e.g., "X من 7 أيام").
/// Handles proper grammar for both the count and the total.
String formatDaysOutOf(int count, int total) {
  final countFormatted = formatDays(count);
  // For "من 7 أيام", we use plural form since 7 is greater than 10 (always plural)
  return '$countFormatted من ${convertToEasternArabicNumerals(total.toString())} أيام';
}
