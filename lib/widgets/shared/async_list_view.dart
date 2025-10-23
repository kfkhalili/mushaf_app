import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AsyncItemBuilder<T> = Widget Function(BuildContext context, T item);

class AsyncListView<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final AsyncItemBuilder<T> itemBuilder;
  final String errorText;

  const AsyncListView({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.errorText = 'Error loading list',
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (itemList) => ListView.separated(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          final T item = itemList[index];
          return itemBuilder(context, item);
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 24, endIndent: 24),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('$errorText: $err')),
    );
  }
}
