import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  static const routeName = 'inventory';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('库存')),
      body: const SafeArea(
        top: false,
        child: Center(
          child: AppEmptyState(
            icon: Icons.kitchen_outlined,
            title: '还没有库存记录',
            message: '入库后的母乳会按最早使用时间排列在这里。',
          ),
        ),
      ),
    );
  }
}
