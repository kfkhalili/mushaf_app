import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart';

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;
  final bool isMemorizationMode;
  final Function(int) onAyahReveal;
  final int memorizationAyahIndex;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.isMemorizationMode,
    required this.onAyahReveal,
    required this.memorizationAyahIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    final asyncPageAyahs = ref.watch(pageAyahsProvider(pageNumber));
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: asyncPageData.when(
          data: (pageData) {
            final pageNum = convertToEasternArabicNumerals(
              pageNumber.toString(),
            );

            // WHY: Using a Column as the root of the body ensures that the
            // header, content (Expanded), and footer are laid out vertically
            // in the correct order and DO NOT overlap.
            return Column(
              children: [
                _buildPermanentHeader(context, pageData),
                // WHY: Expanded widget takes up all remaining vertical space
                // between the header and footer for the page content.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: pageHorizontalPadding,
                    ),
                    child: isMemorizationMode
                        ? asyncPageAyahs.when(
                            data: (ayahs) => _MemorizationView(
                              pageData: pageData,
                              ayahsOnPage: ayahs,
                              currentVisibleAyahIndex: memorizationAyahIndex,
                              onTap: () => onAyahReveal(ayahs.length),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => Center(child: Text('Error: $e')),
                          )
                        : _ReadingView(pageData: pageData),
                  ),
                ),
                _buildPermanentFooter(context, pageNum),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(pageHorizontalPadding),
              child: Text(
                'Failed to load page $pageNumber.\n\nError: $err',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermanentHeader(BuildContext context, PageData pageData) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final headerStyle = TextStyle(fontSize: 24, color: textColor);
    final surahNameStyle = TextStyle(fontSize: 28, color: textColor);

    final String juzGlyphString =
        'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
    final String surahNameGlyphString = (pageData.pageSurahNumber > 0)
        ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
        : '';

    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: headerHorizontalPadding,
        right: headerHorizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Juz Glyph
          SizedBox(
            width: 150,
            child: Text(
              juzGlyphString,
              style: headerStyle.copyWith(fontFamily: quranCommonFontFamily),
              textAlign: TextAlign.left,
            ),
          ),
          // Right Side: Surah Name
          SizedBox(
            width: 150,
            child: Text(
              surahNameGlyphString,
              style: surahNameStyle.copyWith(fontFamily: surahNameFontFamily),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermanentFooter(BuildContext context, String pageNum) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: footerBottomPadding,
        right: footerRightPadding,
        left: footerLeftPadding,
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Text(
          pageNum,
          style: footerPageNumStyle.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

// --- Content Widgets ---

class _ReadingView extends StatelessWidget {
  final PageData pageData;
  const _ReadingView({required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: pageData.layout.lines
          .map(
            (line) =>
                LineWidget(line: line, pageFontFamily: pageData.pageFontFamily),
          )
          .toList(),
    );
  }
}

class _MemorizationView extends StatelessWidget {
  final PageData pageData;
  final List<Ayah> ayahsOnPage;
  final int currentVisibleAyahIndex;
  final VoidCallback onTap;

  const _MemorizationView({
    required this.pageData,
    required this.ayahsOnPage,
    required this.currentVisibleAyahIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (ayahsOnPage.isEmpty) {
      return const Center(child: Text("No ayahs on this page."));
    }

    final List<Word> wordsToDisplay = [];
    for (
      int i = 0;
      i <= currentVisibleAyahIndex && i < ayahsOnPage.length;
      i++
    ) {
      wordsToDisplay.addAll(ayahsOnPage[i].words);
    }
    if (currentVisibleAyahIndex < ayahsOnPage.length - 1) {
      final Ayah nextAyah = ayahsOnPage[currentVisibleAyahIndex + 1];
      if (nextAyah.words.isNotEmpty) {
        wordsToDisplay.add(nextAyah.words.first);
      }
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = screenWidth / referenceScreenWidth;
    final double dynamicFontSize = (baseFontSize * scaleFactor).clamp(
      minAyahFontSize,
      maxAyahFontSize,
    );
    final double dynamicLineHeight = (baseLineHeight * scaleFactor).clamp(
      minLineHeight,
      maxLineHeight,
    );

    // This GestureDetector is internal to the memorization view and only handles revealing ayahs.
    return GestureDetector(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Wrap(
          textDirection: TextDirection.rtl,
          runSpacing: 8.0,
          spacing: 4.0,
          children: wordsToDisplay.map((word) {
            return Text(
              word.text,
              style: TextStyle(
                fontFamily: pageData.pageFontFamily,
                fontSize: dynamicFontSize,
                height: dynamicLineHeight,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textScaler: const TextScaler.linear(1.0),
            );
          }).toList(),
        ),
      ),
    );
  }
}
