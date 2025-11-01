import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/shared/async_list_view.dart';

void main() {
  group('AsyncListView', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncListView<String>(
              asyncValue: AsyncValue.loading(),
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error occurs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncListView<String>(
              asyncValue: AsyncValue.error('Test error', StackTrace.empty),
              itemBuilder: (context, item) => ListTile(title: Text(item)),
              errorText: 'Custom error message',
            ),
          ),
        ),
      );

      expect(find.text('Custom error message: Test error'), findsOneWidget);
    });

    testWidgets('shows list items when data is available', (tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncListView<String>(
              asyncValue: AsyncValue.data(items),
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2)); // 3 items = 2 dividers
    });

    testWidgets('shows empty list when data is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncListView<String>(
              asyncValue: AsyncValue.data([]),
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('uses default error text when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncListView<String>(
              asyncValue: AsyncValue.error('Test error', StackTrace.empty),
              itemBuilder: (context, item) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      expect(find.text('Error loading list: Test error'), findsOneWidget);
    });
  });
}
