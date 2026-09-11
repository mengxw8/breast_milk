import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/domain/services/inventory_calculator.dart';
import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final statisticsSummaryProvider = FutureProvider<InventorySummary>((ref) {
  return ref
      .watch(milkRepositoryProvider)
      .inventorySummary(DateTime.now().toUtc());
});

final statisticsRecordsProvider = FutureProvider<List<MilkRecord>>((ref) {
  return ref.watch(milkRepositoryProvider).list(const MilkRecordFilter());
});

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});
  static const routeName = 'statistics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(statisticsSummaryProvider);
    final records = ref.watch(statisticsRecordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: SafeArea(
        top: false,
        child: summary.when(
          loading: () => const AppEmptyState(
            icon: Icons.bar_chart_rounded,
            title: '暂无统计数据',
            message: '正在计算统计。',
          ),
          error: (_, _) => const AppEmptyState(
            icon: Icons.error_outline,
            title: '统计读取失败',
            message: '请稍后重试。',
          ),
          data: (value) {
            if (value.physical.bagCount == 0) {
              return const AppEmptyState(
                icon: Icons.bar_chart_rounded,
                title: '暂无统计数据',
                message: '完成第一袋入库后，这里会汇总奶量、袋数和期限。',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(statisticsSummaryProvider);
                ref.invalidate(statisticsRecordsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _MetricGrid(summary: value),
                  const SizedBox(height: 24),
                  Text(
                    '未来 30 天期限',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  records.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text('期限清单暂不可用'),
                    data: (items) {
                      final now = DateTime.now().toUtc();
                      final limit = now.add(const Duration(days: 30));
                      final upcoming = items.where((record) {
                        return record.expiresAtUtc.isAfter(now) &&
                            record.expiresAtUtc.isBefore(limit) &&
                            record.status != MilkStatus.checkedOut &&
                            record.status != MilkStatus.discarded;
                      }).toList();
                      if (upcoming.isEmpty) return const Text('未来 30 天没有期限记录');
                      return Column(
                        children: upcoming
                            .map(
                              (record) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.schedule_outlined),
                                title: Text(
                                  '${record.amountMl} mL · ${record.id}',
                                ),
                                subtitle: Text(
                                  '最终期限 ${DateFormat('M月d日 HH:mm').format(record.expiresAtUtc.toLocal())}',
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});
  final InventorySummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = <({String label, InventoryMetric value})>[
      (label: '可用', value: summary.available),
      (label: '解冻中', value: summary.thawing),
      (label: '冷冻', value: summary.frozen),
      (label: '冷藏', value: summary.refrigerated),
      (label: '过期', value: summary.expired),
      (label: '已出库', value: summary.checkedOut),
      (label: '已丢弃', value: summary.discarded),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 88,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.label),
                const Spacer(),
                Text(
                  '${metric.value.bagCount} 袋 · ${metric.value.totalMl} mL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
