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

    return asyncPageData.when(
      data: (pageData) {
        final hizb = convertToEasternArabicNumerals(
          pageData.hizbNumber.toString(),
        );
        final String juzGlyphString =
            'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
        final String surahNameGlyphString = (pageData.pageSurahNumber > 0)
            ? 'surah${pageData.pageSurahNumber.toString().padLeft(3, '0')} surah-icon'
            : '';
        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        const TextStyle headerStyle = TextStyle(
          fontSize: 24,
          color: Colors.black87,
        );
        const TextStyle surahNameStyle = TextStyle(
          fontSize: 28,
          color: Colors.black87,
        );

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leadingWidth: 150,
            leading: Padding(
              padding: const EdgeInsets.only(right: headerHorizontalPadding),
              child: Center(
                child: Text(
                  surahNameGlyphString,
                  style: surahNameStyle.copyWith(
                    fontFamily: surahNameFontFamily,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: headerHorizontalPadding,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        juzGlyphString,
                        style: headerStyle.copyWith(
                          fontFamily: quranCommonFontFamily,
                        ),
                      ),
                      const SizedBox(width: headerJuzHizbSpacing),
                      Text('حزب $hizb', style: headerStyle),
                    ],
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
                  child: Text(pageNum, style: footerPageNumStyle),
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
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
