import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import '../models.dart';

// WHY: Extracted Surah list display logic into its own widget.
class SurahListView extends ConsumerWidget {
  const SurahListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: Watch the provider to get Surah data.
    final surahsAsync = ref.watch(surahListProvider);

    // WHY: Build the UI based on the async state.
    return surahsAsync.when(
      data: (surahs) => ListView.separated(
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          // WHY: Use the dedicated list item widget.
          return SurahListItem(surah: surah);
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 24, endIndent: 24),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading Surahs: $err')),
    );
  }
}

// WHY: Kept SurahListItem together with the ListView that uses it.
class SurahListItem extends StatelessWidget {
  final SurahInfo surah;

  const SurahListItem({super.key, required this.surah});

  // REMOVED: The _navigateToSurah method is no longer needed.
  // Future<void> _navigateToSurah(BuildContext context, int pageNumber) async { ... }

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
              color: theme.colorScheme.primary,
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
          fontSize: 36, // Keep consistent size
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        // WHY: Use the centralized navigation helper.
        navigateToMushafPage(context, surah.startingPage);
      },
    );
  }
}
