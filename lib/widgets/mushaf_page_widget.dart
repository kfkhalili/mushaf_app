import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart';

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));

    // WHY: Use theme-aware colors instead of hardcoded Colors.black87
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final juzHizbStyle = TextStyle(fontSize: 24, color: textColor);
    final surahNameHeaderStyle = TextStyle(fontSize: 28, color: textColor);
    final footerTextStyle = TextStyle(fontSize: 16, color: textColor);

    return asyncPageData.when(
      data: (pageData) {
        final String juzGlyphString =
            'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
        final String surahNameGlyphString = (pageData.pageSurahNumber > 0)
            ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
            : '';

        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: headerHorizontalPadding,
              ),
              child: Center(
                child: Text(
                  juzGlyphString,
                  style: juzHizbStyle.copyWith(
                    fontFamily: quranCommonFontFamily,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: headerHorizontalPadding,
                ),
                child: Center(
                  child: Text(
                    surahNameGlyphString,
                    style: surahNameHeaderStyle.copyWith(
                      fontFamily: surahNameFontFamily,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: pageBottomPadding,
                  left: pageHorizontalPadding,
                  right: pageHorizontalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: pageData.layout.lines
                      .map(
                        (line) => LineWidget(
                          line: line,
                          pageFontFamily: pageData.pageFontFamily,
                        ),
                      )
                      .toList(),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: footerBottomPadding,
                    right: footerRightPadding,
                    left: footerLeftPadding,
                  ),
                  child: Text(pageNum, style: footerTextStyle),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
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
    );
  }
}
