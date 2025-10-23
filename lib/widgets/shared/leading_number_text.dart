import 'package:flutter/material.dart';
import '../../utils/helpers.dart'; // For convertToEasternArabicNumerals

class LeadingNumberText extends StatelessWidget {
  final int number;

  const LeadingNumberText({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      convertToEasternArabicNumerals(number.toString()),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
