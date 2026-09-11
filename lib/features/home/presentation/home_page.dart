import 'dart:io';

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

final homeInventoryRefreshProvider = Provider<void>((ref) {
  // Avoid leaving a database stream alive after widget tests complete.
  if (Platform.environment['FLUTTER_TEST'] == 'true') return;
  final database = ref.watch(appDatabaseProvider);
  final subscription = database.select(database.milkRecords).watch().listen((
    _,
  ) {
    ref.invalidate(homeInventorySummaryProvider);
    ref.invalidate(homeRecordsProvider);
    ref.invalidate(homeEarliestRecordProvider);
  });
  ref.onDispose(subscription.cancel);
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
                    if (records.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.water_drop_outlined,
                        title: '库存还是空的',
                        message: '完成第一袋母乳入库后，会在这里提示使用顺序和期限。',
                      );
                    }
                    return _PriorityRecords(
                      records: records,
                      nowUtc: DateTime.now().toUtc(),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _PriorityRecords extends StatelessWidget {
  const _PriorityRecords({required this.records, required this.nowUtc});
  final List<MilkRecord> records;
  final DateTime nowUtc;
  @override
  Widget build(BuildContext context) {
    final prioritized =
        records
            .where(
              (r) =>
                  r.status != MilkStatus.checkedOut &&
                  r.status != MilkStatus.discarded,
            )
            .toList()
          ..sort((a, b) => a.storedAtUtc.compareTo(b.storedAtUtc));
    if (prioritized.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.check_circle_outline),
          title: Text('暂无可优先使用记录'),
          subtitle: Text('当前库存期限正常'),
        ),
      );
    }
    return Column(
      children: prioritized
          .take(10)
          .map((r) => _PriorityCard(record: r, nowUtc: nowUtc))
          .toList(),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.record, required this.nowUtc});
  final MilkRecord record;
  final DateTime nowUtc;
  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final expiresIn = record.expiresAtUtc.difference(nowUtc);
    final bestUseIn = record.bestUseAtUtc?.difference(nowUtc);
    final special =
        record.isExpiredAt(nowUtc) ||
        record.status == MilkStatus.thawing ||
        expiresIn <= const Duration(days: 7);
    final near =
        !special &&
        (expiresIn <= const Duration(days: 30) ||
            (bestUseIn != null && bestUseIn <= const Duration(days: 30)));
    final color = special
        ? semantic.softCoral
        : near
        ? semantic.softAmber
        : semantic.softLake;
    final label = special
        ? '特别临期'
        : near
        ? '临期'
        : '正常';
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          special
              ? Icons.warning_amber_rounded
              : near
              ? Icons.schedule_outlined
              : Icons.check_circle_outline,
        ),
        title: Text('${record.amountMl} mL · ${record.id}'),
        subtitle: Text(
          '入库 ${DateFormat('M月d日 HH:mm').format(record.storedAtUtc.toLocal())} · $label',
        ),
        trailing: Text(
          record.status == MilkStatus.thawing
              ? '解冻中'
              : '剩余 ${_daysLabel(expiresIn)}',
        ),
      ),
    );
  }

  String _daysLabel(Duration value) {
    if (value.isNegative) return '已过期';
    if (value.inDays > 0) return '${value.inDays}天';
    return '${value.inHours}小时';
  }
}
