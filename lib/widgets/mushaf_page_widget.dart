import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import 'line_widget.dart';

class MushafPageWidget extends ConsumerWidget {
  final int pageNumber;

  const MushafPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    const headerTextStyle = TextStyle(fontSize: 14, color: Colors.black87);
    const footerTextStyle = TextStyle(fontSize: 16, color: Colors.black87);

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
            automaticallyImplyLeading: false, // Remove back button if present
            title: null,
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,

            // Juz and Hizb on the right (leading in RTL)
            leadingWidth: 150,
            leading: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('جزء $juz', style: headerTextStyle),
                    const SizedBox(width: 12),
                    Text('حزب $hizb', style: headerTextStyle),
                  ],
                ),
              ),
            ),
            // Surah Name on the left (actions in RTL)
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(
                  child: Text(
                    pageData.pageSurahName,
                    style: headerTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Prevent wrapping
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand, // Make stack fill the body
            children: [
              // Use SafeArea to avoid status bar/notches
              SafeArea(
                child: Padding(
                  // Consistent padding L/R, increased bottom for footer
                  padding: const EdgeInsets.only(
                    bottom: 50.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Distribute space evenly
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: pageData.layout.lines
                        .map(
                          (line) => Flexible(
                            // Allow lines to take space but not overflow
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

              // Page number positioned at bottom-right
              Positioned(
                bottom: 16.0,
                right: 24.0, // Increased padding from edge
                child: Text(pageNum, style: footerTextStyle),
              ),
            ],
          ),
        );
      },
      // Keep Loading and Error states simple
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
