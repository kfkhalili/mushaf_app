import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../screens/topic_detail_screen.dart';
import '../utils/helpers.dart';
import '../utils/navigation.dart';

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

    // Get ayah text
    final ayahTextAsync = ref.watch(
      FutureProvider((ref) async {
        final dbService = await ref.watch(databaseServiceProvider.future);
        return dbService.getAyahText(surahNumber, ayahNumber);
      }),
    );

    // Get surah name
    final surahNameAsync = ref.watch(
      FutureProvider((ref) async {
        final dbService = await ref.watch(databaseServiceProvider.future);
        return dbService.getSurahName(surahNumber);
      }),
    );

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
                  child: ayahTextAsync.when(
                    data: (text) => Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                        height: 2.0,
                        fontFamily: 'QuranCommon',
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) {
                      if (kDebugMode) {
                        debugPrint('Error loading ayah text: $error\n$stack');
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
