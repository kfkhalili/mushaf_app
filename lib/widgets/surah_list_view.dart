import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../constants.dart';
import '../models.dart';
import '../screens/mushaf_screen.dart';
import 'shared/async_list_view.dart'; // WHY: Import the new reusable widget
import 'shared/leading_number_text.dart'; // WHY: Import the new reusable widget

// WHY: Extracted Surah list display logic into its own widget.
class SurahListView extends ConsumerWidget {
  const SurahListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: Watch the provider to get Surah data.
    final surahsAsync = ref.watch(surahListProvider);

    // WHY: Use the generic AsyncListView to handle loading/error/data states.
    return AsyncListView<SurahInfo>(
      asyncValue: surahsAsync,
      errorText: 'Error loading Surahs',
      itemBuilder: (context, surah) {
        // WHY: Use the dedicated list item widget.
        return SurahListItem(surah: surah);
      },
    );
  }
}

// WHY: Kept SurahListItem together with the ListView that uses it.
class SurahListItem extends StatelessWidget {
  final SurahInfo surah;

  const SurahListItem({super.key, required this.surah});

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
          // WHY: Use the new reusable LeadingNumberText widget.
          LeadingNumberText(number: surah.surahNumber),
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
        // For StatelessWidget, we need to get WidgetRef from parent ConsumerWidget
        // Navigate without clearing last_page (let the user navigate normally)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MushafScreen(initialPage: surah.startingPage),
          ),
        );
      },
    );
  }
}
