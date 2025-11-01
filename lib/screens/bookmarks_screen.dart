import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../widgets/shared/app_header.dart';
import '../widgets/bookmarks_list_view.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log("BookmarksScreen: build", name: "UI_BUILD");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: '', showBackButton: true),
            const Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: BookmarksListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
