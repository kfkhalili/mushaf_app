import 'package:flutter/material.dart';
import '../widgets/shared/app_header.dart';
import '../widgets/statistics_list_view.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'إحصائيات القراءة', showBackButton: true),
            const Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: StatisticsListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
