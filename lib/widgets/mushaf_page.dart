import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../utils/selectors.dart';
import 'mushaf_line.dart';
import '../constants.dart'; // Import constants
import '../providers/memorization_provider.dart';

class MushafPage extends ConsumerWidget {
  final int pageNumber;

  const MushafPage({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WHY: This line will now work because of the added import.
    final asyncPageData = ref.watch(pageDataProvider(pageNumber));
    final session = ref.watch(memorizationSessionProvider);
    final bool isMemorizing =
        session != null && session.pageNumber == pageNumber;

    // Legacy memorization removed

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    final metrics = ResponsiveMetrics.of(context);
    final footerTextStyle = TextStyle(
      fontSize: metrics.footerFontSize(16),
      color: textColor,
    );

    return asyncPageData.when(
      data: (pageData) {
        final visibility = computeMemorizationVisibility(
          pageData.layout,
          isMemorizing ? session : null,
        );

        final pageNum = convertToEasternArabicNumerals(pageNumber.toString());

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: metrics.pagePadding(top: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: pageData.layout.lines.map((line) {
                    return MushafLine(
                      line: line,
                      pageFontFamily: pageData.pageFontFamily,
                      isMemorizationMode: isMemorizing,
                      wordsToShow: visibility.visibleWords,
                      ayahOpacities: visibility.ayahOpacity,
                    );
                  }).toList(),
                ),
              ),
              Align(
                alignment: (pageNumber % 2 != 0)
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Padding(
                  padding: metrics.footerPadding(),
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


