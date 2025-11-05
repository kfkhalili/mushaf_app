import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers.dart';
import '../screens/topic_detail_screen.dart';
import '../utils/helpers.dart';
import '../utils/navigation.dart';
import '../constants.dart';

/// Screen showing detailed information about a specific ayah
class AyahDetailsScreen extends ConsumerWidget {
  final int surahNumber;
  final int ayahNumber;

  const AyahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Get ayah display data (words, page number, font)
    final ayahDisplayAsync = ref.watch(
      ayahDisplayDataProvider(surahNumber, ayahNumber),
    );

    // Get surah name
    final surahNameAsync = ref.watch(surahNameProvider(surahNumber));

    // Get topics for this ayah
    final topicsAsync = ref.watch(
      topicsForAyahProvider(surahNumber, ayahNumber),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          surahNameAsync.when(
            data: (name) =>
                '$name - آية ${convertToEasternArabicNumerals(ayahNumber.toString())}',
            loading: () =>
                'آية ${convertToEasternArabicNumerals(ayahNumber.toString())}',
            error: (error, stack) =>
                'آية ${convertToEasternArabicNumerals(ayahNumber.toString())}',
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              // Ayah text section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ayahDisplayAsync.when(
                    data: (displayData) {
                      final words = displayData.words;
                      final fontFamily = displayData.fontFamily;

                      if (words.isEmpty) {
                        return Text(
                          'لا يوجد نص للآية',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textDirection: TextDirection.rtl,
                        );
                      }

                      // Calculate responsive font size like mushaf screen
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;
                      final widthScale = screenWidth / referenceScreenWidth;
                      final heightScale = screenHeight / referenceScreenHeight;
                      final scaleFactor = math.min(widthScale, heightScale);

                      final userFontSize = ref.watch(fontSizeSettingProvider);
                      final unclampedDynamicFontSize =
                          userFontSize * scaleFactor;
                      final fontSize = unclampedDynamicFontSize.clamp(
                        minAyahFontSize,
                        maxAyahFontSize,
                      );

                      final layout = ref.watch(mushafLayoutSettingProvider);
                      final lineHeight =
                          layoutLineHeights[layout] ?? baseLineHeight;

                      final baseTextColor =
                          theme.textTheme.bodyLarge?.color ?? Colors.black;

                      // Display words as individual widgets in a Wrap, allowing wrapping to next line
                      // WHY: Wrap allows words to flow to next line when they don't fit, preventing overflow
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: words.map((word) {
                            return Text(
                              word.text,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: fontSize,
                                height: lineHeight,
                                color: baseTextColor,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) {
                      if (kDebugMode) {
                        debugPrint(
                          'Error loading ayah display: $error\n$stack',
                        );
                      }
                      return Text(
                        'خطأ في تحميل نص الآية',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textDirection: TextDirection.rtl,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Related Topics Section
              Text(
                'المواضيع ذات الصلة',
                style: theme.textTheme.titleLarge,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              topicsAsync.when(
                data: (topics) {
                  // Filter out topics without Arabic names
                  final topicsWithArabic = topics
                      .where((t) => t.arabicName.isNotEmpty)
                      .toList();

                  if (topicsWithArabic.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'لا توجد مواضيع مرتبطة بهذه الآية',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: topicsWithArabic.map((topic) {
                      return InkWell(
                        onTap: () {
                          pushSlideFromRight(
                            context,
                            TopicDetailScreen(topicId: topic.topicId),
                          );
                        },
                        child: Chip(
                          label: Text(
                            topic.arabicName,
                            textDirection: TextDirection.rtl,
                          ),
                          onDeleted: null,
                          deleteIcon: null,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) {
                  if (kDebugMode) {
                    debugPrint('Error loading topics: $error\n$stack');
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'خطأ في تحميل المواضيع',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
