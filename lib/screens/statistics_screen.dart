import 'package:flutter/material.dart';
import '../widgets/shared/base_screen.dart';
import '../widgets/statistics_list_view.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'إحصائيات القراءة',
      showBackButton: true,
      body: const StatisticsListView(),
    );
  }
}
