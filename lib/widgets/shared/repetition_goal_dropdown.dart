import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/mushaf_screen.dart';
import '../../utils/helpers.dart';

class RepetitionGoalDropdown extends ConsumerWidget {
  const RepetitionGoalDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final memorizationState = ref.watch(memorizationProvider);
    final currentRepetitionGoal = memorizationState.repetitionGoal;

    // Define the repetition goal options
    const List<int> repetitionGoalOptions = [3, 5, 7, 10, 15, 20];

    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: repetitionGoalOptions.contains(currentRepetitionGoal)
          ? currentRepetitionGoal
          : repetitionGoalOptions.first,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      selectedItemBuilder: (BuildContext context) {
        return repetitionGoalOptions.map<Widget>((int goal) {
          return Text(
            convertToEasternArabicNumerals(goal.toString()),
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: repetitionGoalOptions.map((goal) {
        return DropdownMenuItem<int>(
          value: goal,
          child: Text(
            convertToEasternArabicNumerals(goal.toString()),
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (int? goal) {
        if (goal != null) {
          ref.read(memorizationProvider.notifier).setRepetitionGoal(goal);
        }
      },
    );
  }
}
