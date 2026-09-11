import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/domain/services/inventory_calculator.dart';
import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:breast_milk/shared/widgets/milk_drop_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final homeInventorySummaryProvider = FutureProvider<InventorySummary>((ref) {
  return ref
      .watch(milkRepositoryProvider)
      .inventorySummary(DateTime.now().toUtc());
});

final homeRecordsProvider = FutureProvider<List<MilkRecord>>((ref) {
  return ref.watch(milkRepositoryProvider).list(const MilkRecordFilter());
});

final homeEarliestRecordProvider = FutureProvider<MilkRecord?>((ref) {
  return ref
      .watch(milkRepositoryProvider)
      .earliestUsable(DateTime.now().toUtc());
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    final summary = ref.watch(homeInventorySummaryProvider);
    final earliest = ref.watch(homeEarliestRecordProvider);
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
                  summary.when(
                    data: (value) => Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          '${value.available.bagCount} 袋',
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          '${value.available.totalMl} mL',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    error: (_, _) =>
                        Text('库存读取失败', style: theme.textTheme.headlineSmall),
                    loading: () =>
                        Text('正在读取', style: theme.textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 8),
                  earliest.when(
                    data: (record) => Text(
                      record == null
                          ? '入库后会显示最早需要使用的日期'
                          : '最早需使用：${DateFormat('M月d日 HH:mm').format((record.bestUseAtUtc ?? record.expiresAtUtc).toLocal())}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    error: (_, _) => Text(
                      '期限信息暂不可用',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    loading: () => Text(
                      '正在计算期限',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
                    onPressed: () => context.push('/intake'),
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
            ref
                .watch(homeRecordsProvider)
                .when(
                  loading: () => const Text('正在读取风险提醒'),
                  error: (_, _) => const Text('风险提醒暂不可用'),
                  data: (records) {
                    final now = DateTime.now().toUtc();
                    final risks = records
                        .where(
                          (record) =>
                              record.isExpiredAt(now) ||
                              record.status == MilkStatus.thawing,
                        )
                        .toList();
                    if (records.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.water_drop_outlined,
                        title: '库存还是空的',
                        message: '完成第一袋母乳入库后，会在这里提示使用顺序和期限。',
                      );
                    }
                    return _RiskSummary(count: risks.length);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _RiskSummary extends StatelessWidget {
  const _RiskSummary({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(
        count == 0 ? Icons.check_circle_outline : Icons.warning_amber_rounded,
      ),
      title: Text(count == 0 ? '暂无风险提醒' : ' 袋需要处理'),
      subtitle: Text(count == 0 ? '当前库存期限正常' : '请优先查看库存列表中的期限和解冻状态'),
    ),
  );
}
