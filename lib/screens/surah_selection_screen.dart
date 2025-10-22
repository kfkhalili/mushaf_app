import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../constants.dart';
import 'mushaf_screen.dart';
import '../utils/helpers.dart';
import '../models.dart';
import '../widgets/juz_list_view.dart';

class SurahSelectionScreen extends ConsumerStatefulWidget {
  const SurahSelectionScreen({super.key});

  @override
  ConsumerState<SurahSelectionScreen> createState() =>
      _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends ConsumerState<SurahSelectionScreen> {
  int _currentIndex = 2; // 0: Page, 1: Juz, 2: Surah

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0: // Page
        return const Center(child: Text("Page View (Not Implemented)"));
      case 1: // Juz'
        return const JuzListView();
      case 2: // Surah (Default)
      default:
        final surahsAsync = ref.watch(surahListProvider);
        return surahsAsync.when(
          data: (surahs) => ListView.separated(
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              // WHY: Correctly pass the 'surah' named parameter.
              return SurahListItem(surah: surah);
            },
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 24, endIndent: 24),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading Surahs: $err')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double barHeight = 64.0;
    const double labelFontSize = 26.0;

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
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Expanded(child: _buildCurrentView()),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF212121),
        padding: EdgeInsets.zero,
        height: barHeight,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: barHeight,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: labelFontSize,
              color: Colors.grey.shade400, // Unselected color
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 0),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 0
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'الصفحات',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 0
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 1
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'الأجزاء',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 1
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 2),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, barHeight),
                    foregroundColor: _currentIndex == 2
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  child: Text(
                    'السور',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: _currentIndex == 2
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SurahListItem remains unchanged
class SurahListItem extends StatelessWidget {
  final SurahInfo surah;

  const SurahListItem({super.key, required this.surah});

  Future<void> _navigateToSurah(BuildContext context, int pageNumber) async {
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
          fontSize: 36,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        _navigateToSurah(context, surah.startingPage);
      },
    );
  }
}
