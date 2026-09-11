import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/models/milk_status_event.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:breast_milk/shared/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final inventoryRecordsProvider = FutureProvider.autoDispose<List<MilkRecord>>((
  ref,
) {
  return ref
      .watch(milkRepositoryProvider)
      .list(const MilkRecordFilter())
      .catchError((_) => <MilkRecord>[]);
});

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});
  static const routeName = 'inventory';

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  MilkStatus? _statusFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(inventoryRecordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('库存')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: '搜索编号或备注',
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                children: [
                  _statusChip(null, '全部'),
                  for (final status in [
                    MilkStatus.frozenInStock,
                    MilkStatus.refrigeratedInStock,
                    MilkStatus.thawing,
                    MilkStatus.expired,
                  ])
                    _statusChip(status, _statusLabel(status)),
                ],
              ),
            ),
            Expanded(
              child: records.when(
                loading: () => const Center(child: Text('正在读取库存')),
                error: (_, _) => const AppEmptyState(
                  icon: Icons.kitchen_outlined,
                  title: '还没有库存记录',
                  message: '库存暂时不可用，请稍后重试。',
                ),
                data: (items) {
                  final visible = items.where((item) {
                    final statusOk =
                        _statusFilter == null || item.status == _statusFilter;
                    final query = _search.trim();
                    return statusOk &&
                        (query.isEmpty ||
                            item.id.contains(query) ||
                            item.foodNotes.contains(query));
                  }).toList();
                  if (visible.isEmpty) {
                    return const Center(
                      child: AppEmptyState(
                        icon: Icons.kitchen_outlined,
                        title: '还没有库存记录',
                        message: '入库后的母乳会按最早使用时间排列在这里。',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(inventoryRecordsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _RecordTile(
                        record: visible[index],
                        onTap: () => _showDetails(visible[index]),
                        onDelete: () => _deleteRecord(visible[index]),
                        onDiscard: () => _discardRecord(visible[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  FilterChip _statusChip(MilkStatus? status, String label) => FilterChip(
    label: Text(label),
    selected: _statusFilter == status,
    onSelected: (_) => setState(() => _statusFilter = status),
  );

  String _statusLabel(MilkStatus status) => switch (status) {
    MilkStatus.frozenInStock => '冷冻在库',
    MilkStatus.refrigeratedInStock => '冷藏在库',
    MilkStatus.thawing => '解冻中',
    MilkStatus.expired => '已过期',
    _ => status.name,
  };

  Future<void> _showDetails(MilkRecord record) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RecordDetails(
        record: record,
        statusLabel: _statusLabel,
        events: ref.read(milkRepositoryProvider).eventsFor(record.id),
        onAction: (action) async {
          Navigator.pop(context);
          try {
            await ref
                .read(milkRepositoryProvider)
                .transition(
                  TransitionMilkRecordCommand(
                    id: record.id,
                    action: action,
                    occurredAtUtc: DateTime.now().toUtc(),
                  ),
                );
            ref.invalidate(inventoryRecordsProvider);
            ref.invalidate(homeInventorySummaryProvider);
            ref.invalidate(homeEarliestRecordProvider);
            ref.invalidate(homeRecordsProvider);
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('当前状态不允许此操作')));
            }
          }
        },
      ),
    );
  }

  Future<bool> _discardRecord(MilkRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认标记丢弃'),
        content: Text('确定将编号  标记为已丢弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('标记丢弃'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    try {
      await ref
          .read(milkRepositoryProvider)
          .transition(
            TransitionMilkRecordCommand(
              id: record.id,
              action: MilkAction.discard,
              occurredAtUtc: DateTime.now().toUtc(),
            ),
          );
      ref.invalidate(inventoryRecordsProvider);
      ref.invalidate(homeInventorySummaryProvider);
      ref.invalidate(homeEarliestRecordProvider);
      ref.invalidate(homeRecordsProvider);
      return true;
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('标记丢弃失败，请重试')));
      return false;
    }
  }

  Future<bool> _deleteRecord(MilkRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除记录'),
        content: Text('确定永久删除编号  吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    try {
      await ref.read(milkRepositoryProvider).deleteById(record.id);
      ref.invalidate(inventoryRecordsProvider);
      ref.invalidate(homeInventorySummaryProvider);
      ref.invalidate(homeEarliestRecordProvider);
      ref.invalidate(homeRecordsProvider);
      return true;
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
      return false;
    }
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.onTap, required this.onDelete, required this.onDiscard});
  final MilkRecord record;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;
  final Future<bool> Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    final status = switch (record.status) {
      MilkStatus.frozenInStock => '冷冻在库',
      MilkStatus.refrigeratedInStock => '冷藏在库',
      MilkStatus.thawing => '解冻中',
      MilkStatus.expired => '已过期',
      MilkStatus.checkedOut => '已出库',
      MilkStatus.discarded => '已丢弃',
    };
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.water_drop_outlined),
        title: Text('${record.amountMl} mL · $status'),
        subtitle: Text(
          '${record.id}\n到期 ${DateFormat('M月d日 HH:mm').format(record.expiresAtUtc.toLocal())}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
      ),
    );
  }
}

class _RecordDetails extends StatelessWidget {
  const _RecordDetails({
    required this.record,
    required this.statusLabel,
    required this.events,
    required this.onAction,
  });
  final MilkRecord record;
  final String Function(MilkStatus) statusLabel;
  final Future<List<MilkStatusEvent>> events;
  final Future<void> Function(MilkAction) onAction;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (record.status == MilkStatus.frozenInStock) {
      actions.add(
        FilledButton.icon(
          onPressed: () => onAction(MilkAction.startThawing),
          icon: const Icon(Icons.ac_unit),
          label: const Text('开始解冻'),
        ),
      );
    }
    if ({
      MilkStatus.frozenInStock,
      MilkStatus.refrigeratedInStock,
      MilkStatus.thawing,
    }.contains(record.status)) {
      actions.add(
        FilledButton.icon(
          onPressed: () => onAction(MilkAction.checkOut),
          icon: const Icon(Icons.output_rounded),
          label: const Text('整袋出库'),
        ),
      );
    }
    if (record.status == MilkStatus.checkedOut) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => onAction(MilkAction.undoCheckOut),
          icon: const Icon(Icons.undo_rounded),
          label: const Text('撤销出库'),
        ),
      );
    }
    if (record.status == MilkStatus.expired) {
      actions.add(
        FilledButton.icon(
          onPressed: () => onAction(MilkAction.discard),
          icon: const Icon(Icons.delete_outline),
          label: const Text('标记丢弃'),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('库存详情', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(record.id, style: Theme.of(context).textTheme.titleMedium),
              Text('${record.amountMl} mL · ${statusLabel(record.status)}'),
              Text(
                '入库：${DateFormat('yyyy年M月d日 HH:mm').format(record.storedAtUtc.toLocal())}',
              ),
              Text(
                '最终期限：${DateFormat('yyyy年M月d日 HH:mm').format(record.expiresAtUtc.toLocal())}',
              ),
              if (record.foodNotes.isNotEmpty) Text('备注：${record.foodNotes}'),
              const SizedBox(height: 16),
              FutureBuilder<List<MilkStatusEvent>>(
                future: events,
                builder: (context, snapshot) => ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  initiallyExpanded: true,
                  title: const Text('状态时间线'),
                  children: [
                    if (snapshot.hasError)
                      const ListTile(title: Text('时间线暂不可用'))
                    else if (snapshot.data case final history?
                        when history.isNotEmpty)
                      ...history.map(
                        (event) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.circle, size: 10),
                          title: Text(_eventLabel(event.type)),
                          subtitle: Text(
                            DateFormat('yyyy年M月d日 HH:mm')
                                .format(event.occurredAtUtc.toLocal()),
                          ),
                        ),
                      )
                    else
                      const ListTile(title: Text('暂无状态事件')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: action,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _eventLabel(MilkStatusEventType type) => switch (type) {
  MilkStatusEventType.created => '创建记录',
  MilkStatusEventType.thawingStarted => '开始解冻',
  MilkStatusEventType.checkedOut => '整袋出库',
  MilkStatusEventType.checkOutUndone => '撤销出库',
  MilkStatusEventType.expired => '标记过期',
  MilkStatusEventType.discarded => '标记丢弃',
};
