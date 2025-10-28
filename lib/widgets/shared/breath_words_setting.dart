import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../utils/helpers.dart';

class BreathWordsSettingWidget extends ConsumerWidget {
  const BreathWordsSettingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentBreathWords = ref.watch(breathWordsSettingProvider);

    // Define the breath word options
    const List<int> breathWordOptions = [5, 10, 15, 20, 30, 40];

    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: breathWordOptions.contains(currentBreathWords)
          ? currentBreathWords
          : breathWordOptions.first,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      selectedItemBuilder: (BuildContext context) {
        return breathWordOptions.map<Widget>((int words) {
          return Text(
            convertToEasternArabicNumerals(words.toString()),
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: breathWordOptions.map((words) {
        return DropdownMenuItem<int>(
          value: words,
          child: Text(
            convertToEasternArabicNumerals(words.toString()),
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (int? words) {
        if (words != null) {
          ref.read(breathWordsSettingProvider.notifier).setBreathWords(words);
        }
      },
    );
  }
}
