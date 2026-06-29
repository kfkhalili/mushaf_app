import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/ayah_context_menu.dart';

import '../support/harness.dart';

void main() {
  group('AyahContextMenu', () {
    testWidgets('renders context menu with surah and ayah', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Stack(
            children: [
              const SizedBox(),
              AyahContextMenu(
                surahNumber: 1,
                ayahNumber: 1,
                tapPosition: const Offset(100, 100),
                onDismiss: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.byType(AyahContextMenu), findsOneWidget);
    });

    testWidgets('renders with provider scope', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Stack(
            children: [
              const SizedBox(),
              AyahContextMenu(
                surahNumber: 1,
                ayahNumber: 1,
                tapPosition: const Offset(100, 100),
                onDismiss: () {},
              ),
            ],
          ),
        ),
      );

      // Context menu should be visible
      expect(find.byType(AyahContextMenu), findsOneWidget);
    });
  });
}
