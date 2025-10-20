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

    // Create two separate styles for individual control
    const TextStyle juzHizbStyle = TextStyle(
      fontSize: 24,
      color: Colors.black87,
    );
    const TextStyle surahNameHeaderStyle = TextStyle(
      fontSize: 28,
      color: Colors.black87,
    );

    const TextStyle footerTextStyle = footerPageNumStyle;

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

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,

            // Surah Name on the right (leading in RTL)
            leadingWidth: 150,
            leading: Padding(
              padding: const EdgeInsets.only(right: headerHorizontalPadding),
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
            // Juz Glyph and Hizb Text on the left (actions in RTL)
            actions: [
              Padding(
                // WHY: Added 'right' padding to push the content away from the right screen edge.
                // The 'left' padding remains to keep it from touching the center.
                padding: const EdgeInsets.only(
                  left: headerHorizontalPadding,
                  right: headerHorizontalPadding, // <-- ADDED THIS PADDING
                ),
                child: Align(
                  // Use centerRight to align the content correctly on the right side.
                  alignment: Alignment.centerRight, // <-- CORRECTED ALIGNMENT
                  child: Row(
                    // WHY: This forces the children of the Row to be laid out
                    // from right to left, placing the Juz glyph first (on the right).
                    textDirection: TextDirection.rtl,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        juzGlyphString,
                        style: juzHizbStyle.copyWith(
                          fontFamily: quranCommonFontFamily,
                        ),
                      ),
                      const SizedBox(width: headerJuzHizbSpacing),
                      Text('حزب $hizb', style: juzHizbStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
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
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
