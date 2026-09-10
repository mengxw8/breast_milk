import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  static const routeName = 'statistics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: const SafeArea(
        top: false,
        child: Center(
          child: AppEmptyState(
            icon: Icons.bar_chart_rounded,
            title: '暂无统计数据',
            message: '完成第一袋入库后，这里会汇总奶量、袋数和期限。',
          ),
        ),
      ),
    );
  }
}
