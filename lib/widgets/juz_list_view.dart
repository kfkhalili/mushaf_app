import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models.dart';
import '../constants.dart';
import '../utils/helpers.dart';
import 'shared/async_list_view.dart'; // WHY: Import the new reusable widget
import 'shared/leading_number_text.dart'; // WHY: Import the new reusable widget

class JuzListView extends ConsumerWidget {
  const JuzListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzListAsync = ref.watch(juzListProvider);

    // WHY: Use the generic AsyncListView to handle loading/error/data states.
    return AsyncListView<JuzInfo>(
      asyncValue: juzListAsync,
      errorText: 'Error loading Juz list',
      itemBuilder: (context, juzInfo) {
        return JuzListItem(juzInfo: juzInfo);
      },
    );
  }
}

class JuzListItem extends StatelessWidget {
  final JuzInfo juzInfo;

  const JuzListItem({super.key, required this.juzInfo});

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
          // WHY: Use the new reusable LeadingNumberText widget.
          LeadingNumberText(number: juzInfo.juzNumber),
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
          // WHY: Use the centralized navigation helper.
          navigateToMushafPage(context, juzInfo.startingPage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لم يتم العثور على صفحة البداية للجزء ${convertToEasternArabicNumerals(juzInfo.juzNumber.toString())}',
              ),
            ),
          );
        }
      },
    );
  }
}
