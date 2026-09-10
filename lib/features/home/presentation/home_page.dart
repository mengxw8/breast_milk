import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:breast_milk/shared/widgets/milk_drop_mark.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const MilkDropMark(size: 54),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('吨吨吨', style: theme.textTheme.titleLarge),
                      Text(
                        '母乳库存管理',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/settings'),
                  tooltip: '打印机未连接，前往设置',
                  icon: const Icon(Icons.print_disabled_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: semantic.softCoral,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('可用库存', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text('0 袋', style: theme.textTheme.headlineSmall),
                      Text('0 mL', style: theme.textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '入库后会显示最早需要使用的日期',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('母乳入库'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: semantic.scan,
                    ),
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('扫码出库'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('优先使用', style: theme.textTheme.titleLarge),
            const AppEmptyState(
              icon: Icons.water_drop_outlined,
              title: '库存还是空的',
              message: '完成第一袋母乳入库后，会在这里提示使用顺序和期限。',
            ),
          ],
        ),
      ),
    );
  }
}
