import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../widgets/shared/base_screen.dart';
import '../widgets/bookmarks_list_view.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log("BookmarksScreen: build", name: "UI_BUILD");
    return BaseScreen(
      title: 'العلامات المرجعية',
      showBackButton: true,
      body: const Directionality(
        textDirection: TextDirection.rtl,
        child: BookmarksListView(),
      ),
    );
  }
}
