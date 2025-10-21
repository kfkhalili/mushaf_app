import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../constants.dart';
import 'mushaf_screen.dart';
import '../utils/helpers.dart';
import '../models.dart';

class SurahSelectionScreen extends ConsumerWidget {
  const SurahSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'quran',
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: 50,
                  color: theme.colorScheme.primary, // Theme-aware color
                ),
              ),
            ),
            Expanded(
              child: surahsAsync.when(
                data: (surahs) => ListView.separated(
                  itemCount: surahs.length,
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    return SurahListItem(surah: surah);
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 24, endIndent: 24),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error loading Surahs: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurahListItem extends StatelessWidget {
  final SurahInfo surah;

  const SurahListItem({super.key, required this.surah});

  Future<void> _navigateToSurah(BuildContext context, int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', pageNumber);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MushafScreen(initialPage: pageNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahNumPadded = surah.surahNumber.toString().padLeft(3, '0');
    final surahNameGlyph = 'surah$surahNumPadded surah-icon';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            convertToEasternArabicNumerals(surah.surahNumber.toString()),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Theme-aware color
            ),
          ),
          const SizedBox(width: 8),
          Text(
            surah.revelationPlace == 'makkah' ? 'مكية' : 'مدنية',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        surahNameGlyph,
        style: TextStyle(
          fontFamily: surahNameFontFamily,
          fontSize: 32,
          color: theme.textTheme.bodyLarge?.color, // Theme-aware color
        ),
      ),
      onTap: () {
        _navigateToSurah(context, surah.startingPage);
      },
    );
  }
}
