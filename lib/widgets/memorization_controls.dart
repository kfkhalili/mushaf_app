import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/memorization_provider.dart';

/// Widget that displays memorization controls (Reveal button or Grade buttons)
class MemorizationControls extends ConsumerWidget {
  final int currentAyahIndex;
  final int totalAyatOnPage;
  final bool isAyahHidden;

  const MemorizationControls({
    super.key,
    required this.currentAyahIndex,
    required this.totalAyatOnPage,
    required this.isAyahHidden,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.primary;
    final foregroundColor = theme.colorScheme.onPrimary;
    final errorColor = theme.colorScheme.error;
    final warningColor = Colors.orange;
    final successColor = Colors.green;

    // Show reveal button if ayah is hidden
    if (isAyahHidden) {
      return GestureDetector(
        onTap: () {
          ref.read(memorizationSessionProvider.notifier).revealAyah(currentAyahIndex);
        },
        child: Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: foregroundColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.visibility,
            color: foregroundColor,
            size: 32,
          ),
        ),
      );
    }

    // Show grade buttons if ayah is revealed
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hard button
          _GradeButton(
            label: '❌',
            text: 'Hard',
            color: errorColor,
            onPressed: () => _gradeAyah(ref, 1),
          ),
          const SizedBox(width: 8),
          // Medium button
          _GradeButton(
            label: '⚠️',
            text: 'Medium',
            color: warningColor,
            onPressed: () => _gradeAyah(ref, 2),
          ),
          const SizedBox(width: 8),
          // Easy button
          _GradeButton(
            label: '✅',
            text: 'Easy',
            color: successColor,
            onPressed: () => _gradeAyah(ref, 3),
          ),
        ],
      ),
    );
  }

  void _gradeAyah(WidgetRef ref, int masteryLevel) {
    ref.read(memorizationSessionProvider.notifier).gradeAyah(
      ayahIndex: currentAyahIndex,
      masteryLevel: masteryLevel,
      totalAyatOnPage: totalAyatOnPage,
    );
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _GradeButton({
    required this.label,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

