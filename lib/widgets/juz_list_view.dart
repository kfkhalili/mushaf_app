import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart'; // For convertToEasternArabicNumerals
import '../screens/mushaf_screen.dart';

class JuzListView extends ConsumerWidget {
  const JuzListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzListAsync = ref.watch(juzListProvider);

    return juzListAsync.when(
      data: (juzList) => ListView.separated(
        itemCount: juzList.length,
        itemBuilder: (context, index) {
          final juzInfo = juzList[index];
          return JuzListItem(juzInfo: juzInfo);
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 24, endIndent: 24),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading Juz list: $err')),
    );
  }
}

class JuzListItem extends StatelessWidget {
  final JuzInfo juzInfo;

  const JuzListItem({super.key, required this.juzInfo});

  Future<void> _navigateToJuz(BuildContext context, int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_page');

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
    // Glyph using QuranCommon font for "الجزء..."
    final String juzNumberGlyph =
        'juz${juzInfo.juzNumber.toString().padLeft(3, '0')}';
    // WHY: Glyph using QuranCommon font for the Juz' name (e.g., "الم")
    final String juzNameGlyph =
        'j${juzInfo.juzNumber.toString().padLeft(3, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      // WHY: Use a Row similar to SurahListItem to include the Juz' name glyph.
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic, // Align baselines
        children: [
          Text(
            convertToEasternArabicNumerals(juzInfo.juzNumber.toString()),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          // WHY: Add the Juz' name glyph using QuranCommon font.
          Text(
            juzNameGlyph,
            style: TextStyle(
              fontFamily: quranCommonFontFamily, // Use common font
              fontSize: 14, // Smaller size like Meccan/Medinan text
              color: Colors.grey, // Grey color like Meccan/Medinan text
            ),
          ),
        ],
      ),
      trailing: Text(
        juzNumberGlyph, // Display "الجزء الأول", "الجزء الثاني", etc.
        style: TextStyle(
          fontFamily: quranCommonFontFamily, // Use the common font
          fontSize: 32,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        if (juzInfo.startingPage > 0) {
          _navigateToJuz(context, juzInfo.startingPage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not find starting page for Juz ${juzInfo.juzNumber}',
              ),
            ),
          );
        }
      },
    );
  }
}
