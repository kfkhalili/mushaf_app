import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import 'line_widget.dart';
import '../constants.dart'; // Import constants

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    // Use constants for styles
    const TextStyle headerStyle = headerFooterBaseStyle;
    const TextStyle footerStyle = footerPageNumStyle;

    return asyncPageData.when(
      data: (pageData) {
        final juz = convertToEasternArabicNumerals(
          pageData.juzNumber.toString(),
        );
        final hizb = convertToEasternArabicNumerals(
          pageData.hizbNumber.toString(),
        );
        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,

            leadingWidth: 150,
            leading: Padding(
              // Use constant for padding
              padding: const EdgeInsets.only(right: headerHorizontalPadding),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('جزء $juz', style: headerStyle), // Use style constant
                    // Use constant for spacing
                    const SizedBox(width: headerJuzHizbSpacing),
                    Text('حزب $hizb', style: headerStyle), // Use style constant
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                // Use constant for padding
                padding: const EdgeInsets.only(left: headerHorizontalPadding),
                child: Center(
                  child: Text(
                    pageData.pageSurahName,
                    // Use style constant and override fontWeight
                    style: headerStyle.copyWith(fontWeight: FontWeight.bold),
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
              SafeArea(
                child: Padding(
                  // Use constants for padding
                  padding: const EdgeInsets.only(
                    bottom: pageBottomPadding,
                    left: pageHorizontalPadding,
                    right: pageHorizontalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: pageData.layout.lines
                        .map(
                          (line) => Flexible(
                            child: LineWidget(
                              line: line,
                              pageFontFamily: pageData.pageFontFamily,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  // Use constants for padding
                  padding: const EdgeInsets.only(
                    bottom: footerBottomPadding,
                    right: footerRightPadding,
                    left:
                        footerLeftPadding, // Adjusts visual right padding in RTL
                  ),
                  child: Text(
                    pageNum,
                    style: footerStyle,
                  ), // Use style constant
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
            padding: const EdgeInsets.all(
              pageHorizontalPadding,
            ), // Use constant
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
