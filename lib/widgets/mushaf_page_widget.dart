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
  final Set<int> visibleWordIds;

  const MushafPageWidget({
    super.key,
    required this.pageNumber,
    required this.isMemorizationMode,
    required this.visibleWordIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: asyncPageData.when(
          data: (pageData) {
            final pageNum = convertToEasternArabicNumerals(
              pageNumber.toString(),
            );

            return Column(
              children: [
                _buildPermanentHeader(context, pageData),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: pageHorizontalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: pageData.layout.lines
                          .map(
                            (line) => LineWidget(
                              line: line,
                              pageFontFamily: pageData.pageFontFamily,
                              isMemorizationMode: isMemorizationMode,
                              visibleWordIds: visibleWordIds,
                            ),
                          )
                          .toList(),
                    ),
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
          SizedBox(
            width: 150,
            child: Text(
              juzGlyphString,
              style: headerStyle.copyWith(fontFamily: quranCommonFontFamily),
              textAlign: TextAlign.left,
            ),
          ),
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
