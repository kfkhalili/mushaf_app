import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Quran glyph
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'quran',
                style: TextStyle(
                  fontFamily: quranCommonFontFamily,
                  fontSize: 50,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
            // Surah List
            Expanded(
              child: surahsAsync.when(
                data: (surahs) => ListView.builder(
                  itemCount: surahs.length,
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    return SurahListItem(surah: surah);
                  },
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

  @override
  Widget build(BuildContext context) {
    final surahNumPadded = surah.surahNumber.toString().padLeft(3, '0');
    final surahNameGlyph = 'surah$surahNumPadded surah-icon';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      // Right side: Number and details
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            convertToEasternArabicNumerals(surah.surahNumber.toString()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          Text(
            surah.revelationPlace == 'makkah' ? 'مكية' : 'مدنية',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      // Left side: Stylized name
      trailing: Text(
        surahNameGlyph,
        style: const TextStyle(
          fontFamily: surahNameFontFamily,
          fontSize: 26,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        // Navigate to MushafScreen with the correct starting page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MushafScreen(initialPage: surah.startingPage),
          ),
        );
      },
    );
  }
}
