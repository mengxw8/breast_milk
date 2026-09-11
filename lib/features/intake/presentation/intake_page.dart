import 'package:breast_milk/domain/models/food_tag.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/services/expiry_policy.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/intake/application/intake_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class IntakePage extends ConsumerStatefulWidget {
  const IntakePage({super.key});

  static const routeName = 'intake';

  @override
  ConsumerState<IntakePage> createState() => _IntakePageState();
}

class _IntakePageState extends ConsumerState<IntakePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '120');
  final _foodNotesController = TextEditingController();
  final _selectedFoodTags = <String, String>{};

  DateTime _storedAt = DateTime.now();
  MilkStorageMode _storageMode = MilkStorageMode.frozen;
  String? _timeError;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _foodNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodTags = ref.watch(intakeFoodTagsProvider);
    final expiry = const ExpiryPolicy().forStorage(
      mode: _storageMode,
      storedAtUtc: _storedAt.toUtc(),
      timezoneOffsetMinutes: _storedAt.timeZoneOffset.inMinutes,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('母乳入库')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Section(
                title: '入库时间',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(
                        DateFormat('yyyy年M月d日 HH:mm').format(_storedAt),
                      ),
                      subtitle: const Text('用于生成编号和计算期限'),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: _submitting ? null : _pickStoredAt,
                    ),
                    if (_timeError != null)
                      Text(
                        _timeError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: '奶量',
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _submitting ? null : () => _stepAmount(-10),
                      icon: const Icon(Icons.remove_rounded),
                      tooltip: '减少 10 mL',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: '奶量',
                          suffixText: 'mL',
                        ),
                        validator: _validateAmount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: _submitting ? null : () => _stepAmount(10),
                      icon: const Icon(Icons.add_rounded),
                      tooltip: '增加 10 mL',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: '储存方式',
                child: SegmentedButton<MilkStorageMode>(
                  segments: const [
                    ButtonSegment(
                      value: MilkStorageMode.frozen,
                      icon: Icon(Icons.ac_unit_rounded),
                      label: Text('-21°C 冷冻'),
                    ),
                    ButtonSegment(
                      value: MilkStorageMode.refrigerated,
                      icon: Icon(Icons.kitchen_rounded),
                      label: Text('3°C 冷藏'),
                    ),
                  ],
                  selected: {_storageMode},
                  onSelectionChanged: _submitting
                      ? null
                      : (value) => setState(() => _storageMode = value.single),
                ),
              ),
              const SizedBox(height: 16),
              _Section(title: '食物', child: _foodFields(foodTags)),
              const SizedBox(height: 16),
              _ExpiryPreview(window: expiry),
              const SizedBox(height: 16),
              _LabelPreview(
                previewId: _previewId,
                storedAt: _storedAt,
                amountText: _amountController.text,
                storageMode: _storageMode,
                foodNames: _selectedFoodTags.values,
                foodNotes: _foodNotesController.text,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : () => _submit(print: true),
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print_outlined),
                label: const Text('保存并打印标签'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _submitting ? null : () => _submit(print: false),
                icon: const Icon(Icons.save_outlined),
                label: const Text('仅保存，稍后打印'),
              ),
              const SizedBox(height: 12),
              Text(
                '编号末两位会在保存事务中生成，避免预览占用正式编号。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodFields(AsyncValue<List<FoodTag>> foodTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        foodTags.when(
          data: (tags) => tags.isEmpty
              ? const Text('还没有常用食物')
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in tags)
                      FilterChip(
                        label: Text(tag.name),
                        selected: _selectedFoodTags.containsKey(tag.id),
                        onSelected: _submitting
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedFoodTags[tag.id] = tag.name;
                                  } else {
                                    _selectedFoodTags.remove(tag.id);
                                  }
                                });
                              },
                      ),
                  ],
                ),
          error: (_, _) => Row(
            children: [
              const Expanded(child: Text('食物标签加载失败')),
              IconButton(
                onPressed: () => ref.invalidate(intakeFoodTagsProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '重新加载',
              ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _submitting ? null : _addFoodTag,
          icon: const Icon(Icons.add_rounded),
          label: const Text('添加常用食物'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _foodNotesController,
          enabled: !_submitting,
          minLines: 2,
          maxLines: 4,
          maxLength: 80,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: '自由补充，例如食物组合或饮食备注'),
        ),
      ],
    );
  }

  String get _previewId =>
      '${DateFormat('yyyyMMddHHmmss').format(_storedAt)}**';

  String? _validateAmount(String? value) {
    final amount = int.tryParse(value ?? '');
    if (amount == null || amount <= 0) return '请输入大于 0 的整数奶量';
    if (amount > 9999) return '奶量数值过大';
    return null;
  }

  Future<void> _pickStoredAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _storedAt,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_storedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _storedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _timeError = null;
    });
  }

  void _stepAmount(int delta) {
    final current = int.tryParse(_amountController.text) ?? 0;
    final next = (current + delta).clamp(10, 9990);
    setState(() => _amountController.text = next.toString());
  }

  Future<void> _addFoodTag() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加常用食物'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(labelText: '食物名称'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    // Dialog dismissal animates after showDialog completes; dispose afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (name == null || name.isEmpty || !mounted) return;
    try {
      final tag = await ref.read(intakeServiceProvider).saveFoodTag(name);
      if (!mounted) return;
      setState(() => _selectedFoodTags[tag.id] = tag.name);
      ref.invalidate(intakeFoodTagsProvider);
    } catch (_) {
      if (mounted) _showMessage('添加食物失败，请稍后重试');
    }
  }

  Future<void> _submit({required bool print}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_storedAt.isAfter(DateTime.now())) {
      setState(() => _timeError = '入库时间不能晚于当前时间');
      return;
    }
    setState(() {
      _timeError = null;
      _submitting = true;
    });

    try {
      final result = await ref
          .read(intakeServiceProvider)
          .save(
            IntakeRequest(
              storedAt: _storedAt,
              amountMl: int.parse(_amountController.text),
              storageMode: _storageMode,
              foodTagIds: _selectedFoodTags.keys.toList(growable: false),
              foodNames: _selectedFoodTags.values.toList(growable: false),
              foodNotes: _foodNotesController.text,
              printAfterSave: print,
            ),
          );
      if (!mounted) return;
      _invalidateInventory();
      if (result.printState == IntakePrintState.failed) {
        await _resolvePrintFailure(result);
      } else {
        _finish(
          result.record.id,
          result.printState == IntakePrintState.printed
              ? '已保存并发送标签 ${result.record.id}'
              : '已保存 ${result.record.id}',
        );
      }
    } on IntakeFailure catch (error) {
      _showMessage(_intakeFailureMessage(error));
    } catch (_) {
      _showMessage('入库失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resolvePrintFailure(IntakeResult initial) async {
    var result = initial;
    while (mounted && result.printState == IntakePrintState.failed) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final action = await showModalBottomSheet<_PrintFailureAction>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '记录已保存，标签未打印',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(result.printerFailure?.displayMessage ?? '打印机暂时不可用'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, _PrintFailureAction.retry),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重试打印'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pop(context, _PrintFailureAction.settings),
                  icon: const Icon(Icons.settings_bluetooth_rounded),
                  label: const Text('连接打印机'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, _PrintFailureAction.later),
                  child: const Text('稍后打印'),
                ),
              ],
            ),
          ),
        ),
      );
      if (!mounted || action == null) return;
      if (action == _PrintFailureAction.later) {
        _finish(result.record.id, '记录已保存，可稍后重打标签');
        return;
      }
      if (action == _PrintFailureAction.settings) {
        await context.push('/settings/printer');
        continue;
      }
      setState(() => _submitting = true);
      result = await ref
          .read(intakeServiceProvider)
          .retryPrint(result.record, foodNames: _selectedFoodTags.values);
    }
    if (mounted && result.printState == IntakePrintState.printed) {
      _finish(result.record.id, '标签已重新发送 ${result.record.id}');
    }
  }

  void _invalidateInventory() {
    ref
      ..invalidate(homeInventorySummaryProvider)
      ..invalidate(homeEarliestRecordProvider);
  }

  void _finish(String id, String message) {
    _showMessage(message);
    Navigator.of(context).maybePop(id);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _intakeFailureMessage(IntakeFailure failure) {
    return switch (failure.code) {
      'invalid_amount' => '请输入有效奶量',
      'amount_too_large' => '奶量数值过大',
      'future_stored_at' => '入库时间不能晚于当前时间',
      _ => '入库失败，请稍后重试',
    };
  }
}

enum _PrintFailureAction { retry, settings, later }

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExpiryPreview extends StatelessWidget {
  const _ExpiryPreview({required this.window});

  final ExpiryWindow window;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '期限预览',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (window.bestUseAtUtc != null)
            Text('最佳使用：${_formatLocal(window.bestUseAtUtc!)}'),
          Text('最终期限：${_formatLocal(window.expiresAtUtc)}'),
          const SizedBox(height: 6),
          Text(
            '期限为储存建议，请结合实际卫生条件判断。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelPreview extends StatelessWidget {
  const _LabelPreview({
    required this.previewId,
    required this.storedAt,
    required this.amountText,
    required this.storageMode,
    required this.foodNames,
    required this.foodNotes,
  });

  final String previewId;
  final DateTime storedAt;
  final String amountText;
  final MilkStorageMode storageMode;
  final Iterable<String> foodNames;
  final String foodNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final food = foodNames.isNotEmpty
        ? foodNames.take(2).join(' ')
        : foodNotes.trim().isEmpty
        ? '无'
        : foodNotes.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('40 × 30 mm 标签预览', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Expanded(
                              child: Center(
                                child: Icon(Icons.qr_code_2, size: 104),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('MM-dd').format(storedAt)),
                                    Text(DateFormat('HH:mm').format(storedAt)),
                                    Text(
                                      '${amountText.isEmpty ? '--' : amountText} mL',
                                    ),
                                    Text(_storageLabel(storageMode)),
                                    Text(
                                      food,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        previewId,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatLocal(DateTime value) {
  return DateFormat('yyyy年M月d日 HH:mm').format(value.toLocal());
}

String _storageLabel(MilkStorageMode mode) {
  return switch (mode) {
    MilkStorageMode.frozen => '-21°C 冷冻',
    MilkStorageMode.refrigerated => '3°C 冷藏',
  };
}
