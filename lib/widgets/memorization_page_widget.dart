import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart';
import '../constants.dart';

class MemorizationPageWidget extends ConsumerStatefulWidget {
  final int pageNumber;
  const MemorizationPageWidget({super.key, required this.pageNumber});

  @override
  ConsumerState<MemorizationPageWidget> createState() =>
      _MemorizationPageWidgetState();
}

class _MemorizationPageWidgetState
    extends ConsumerState<MemorizationPageWidget> {
  int _currentVisibleAyahIndex = 0;

  void _revealNext(int totalAyahsOnPage) {
    setState(() {
      if (_currentVisibleAyahIndex < totalAyahsOnPage - 1) {
        _currentVisibleAyahIndex++;
      } else {
        // Reset when the whole page is visible and user taps again
        _currentVisibleAyahIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch both the page font data and the ayah-grouped data
    final asyncPageData = ref.watch(pageDataProvider(widget.pageNumber));
    final asyncPageAyahs = ref.watch(pageAyahsProvider(widget.pageNumber));
    final theme = Theme.of(context);

    // Responsive font size logic
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

    // We need data from both providers. A nested .when is a clean way to handle this.
    return asyncPageData.when(
      data: (pageData) {
        // This gives us the pageFontFamily
        return asyncPageAyahs.when(
          data: (ayahsOnPage) {
            if (ayahsOnPage.isEmpty) {
              return const Center(child: Text("No ayahs found on this page."));
            }

            // Build the list of words to display based on the current reveal index
            final List<Word> wordsToDisplay = [];

            // Add words from all ayahs up to the current visible index
            for (int i = 0; i <= _currentVisibleAyahIndex; i++) {
              wordsToDisplay.addAll(ayahsOnPage[i].words);
            }

            // Add the first word of the next ayah as a hint, if it exists
            if (_currentVisibleAyahIndex < ayahsOnPage.length - 1) {
              final Ayah nextAyah = ayahsOnPage[_currentVisibleAyahIndex + 1];
              if (nextAyah.words.isNotEmpty) {
                wordsToDisplay.add(nextAyah.words.first);
              }
            }

            return GestureDetector(
              behavior:
                  HitTestBehavior.opaque, // Ensure the whole area is tappable
              onTap: () => _revealNext(ayahsOnPage.length),
              child: Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      pageHorizontalPadding + 4,
                    ), // A bit more padding
                    // WHY: The Wrap widget is perfect for this mode. It lays out the
                    // word glyphs sequentially and automatically wraps to the next line
                    // when the edge is reached, dynamically recreating the page.
                    child: Wrap(
                      textDirection: TextDirection.rtl,
                      runSpacing: 8.0, // Vertical space between lines
                      spacing: 4.0, // Horizontal space between words
                      children: wordsToDisplay.map((word) {
                        return Text(
                          word.text,
                          style: TextStyle(
                            fontFamily: pageData
                                .pageFontFamily, // Use font from pageData
                            fontSize: dynamicFontSize,
                            height: dynamicLineHeight,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading ayahs: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading page data: $err')),
    );
  }
}
