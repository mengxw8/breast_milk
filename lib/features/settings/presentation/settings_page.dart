import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/domain/services/expiry_policy.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/intake/application/intake_service.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:breast_milk/features/settings/application/backup_file_gateway.dart';
import 'package:breast_milk/features/settings/application/backup_service.dart';
import 'package:breast_milk/features/settings/application/settings_store.dart';
import 'package:breast_milk/features/settings/application/notification_service.dart';
import 'package:breast_milk/features/statistics/presentation/statistics_page.dart';
import 'package:breast_milk/shared/widgets/app_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final settingsValuesProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return SettingsStore(ref.watch(appDatabaseProvider)).read();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  static const routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(settingsValuesProvider);
    final expiry = ref.watch(storageExpiryPolicyProvider);
    final notificationsEnabled =
        values.asData?.value['notifications.enabled'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.print_outlined),
              title: const Text('蓝牙打印机'),
              subtitle: const Text('连接 P203A 并打印测试标签'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/printer'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text('常用食物'),
              subtitle: const Text('管理入库时的常用食物标签'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/food-tags'),
            ),
            const Divider(),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.kitchen_outlined),
              title: const Text('保质期设置'),
              subtitle: expiry.when(
                data: (policy) => Text(
                  '冷藏 ${policy.refrigeratedDays} 天 · 冷冻 ${policy.frozenMonths} 个月\n冷冻最佳使用期 ${policy.frozenBestUseMonths} 个月',
                ),
                loading: () => const Text('正在读取设置'),
                error: (_, _) => const Text('设置读取失败'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: expiry.asData == null
                  ? null
                  : () => _editExpiry(context, ref, expiry.asData!.value),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('到期提醒'),
              subtitle: const Text('仅在存在风险库存时发送每日提醒'),
              value: notificationsEnabled,
              onChanged: values.isLoading
                  ? null
                  : (enabled) async {
                      final service = ref.read(notificationServiceProvider);
                      await service.initialize();
                      if (enabled) {
                        await service.requestPermission();
                        final time =
                            values.asData?.value['notifications.time']
                                as String? ??
                            '09:00';
                        final parts = time.split(':');
                        await service.scheduleDaily(
                          hour: int.tryParse(parts.first) ?? 9,
                          minute: int.tryParse(parts.last) ?? 0,
                        );
                      } else {
                        await service.cancel();
                      }
                      await SettingsStore(ref.read(appDatabaseProvider)).write(
                        'notifications.enabled',
                        enabled,
                        DateTime.now().toUtc(),
                      );
                      ref.invalidate(settingsValuesProvider);
                    },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('提醒时间'),
              subtitle: Text(
                '${values.asData?.value['notifications.time'] ?? '09:00'}，开启提醒后生效',
              ),
              onTap: () => _pickTime(
                context,
                ref,
                values.asData?.value['notifications.time'] as String? ??
                    '09:00',
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.archive_outlined),
              title: const Text('导出数据'),
              subtitle: const Text('导出记录、事件和食物标签 JSON'),
              onTap: () => _export(context, ref),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.restore_outlined),
              title: const Text('导入数据'),
              subtitle: const Text('合并 JSON，不删除本机独有记录'),
              onTap: () => _import(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editExpiry(
    BuildContext context,
    WidgetRef ref,
    ExpiryPolicy current,
  ) async {
    final result = await showDialog<ExpiryPolicy>(
      context: context,
      builder: (_) => _ExpirySettingsDialog(current: current),
    );
    if (result == null || !context.mounted) return;
    try {
      final database = ref.read(appDatabaseProvider);
      final store = SettingsStore(database);
      final now = DateTime.now().toUtc();
      await database.transaction(() async {
        await store.write(
          'expiry.refrigeratedDays',
          result.refrigeratedDays,
          now,
        );
        await store.write('expiry.frozenMonths', result.frozenMonths, now);
        await store.write(
          'expiry.frozenBestUseMonths',
          result.frozenBestUseMonths,
          now,
        );
      });
      ref.invalidate(settingsValuesProvider);
      ref.invalidate(storageExpiryPolicyProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保质期设置已保存')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
      }
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final parts = current.split(':');
    final picked = await showAppTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 9,
        minute: int.tryParse(parts.last) ?? 0,
      ),
    );
    if (picked == null || !context.mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await SettingsStore(ref.read(appDatabaseProvider))
        .write('notifications.time', value, DateTime.now().toUtc());
    if (ref
            .read(settingsValuesProvider)
            .asData
            ?.value['notifications.enabled'] ==
        true) {
      final service = ref.read(notificationServiceProvider);
      await service.initialize();
      await service.scheduleDaily(hour: picked.hour, minute: picked.minute);
    }
    ref.invalidate(settingsValuesProvider);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    var busyOpen = true;
    _showBusyDialog(context, '正在导出，请稍候…');
    try {
      final bytes = await BackupService(ref.read(appDatabaseProvider))
          .exportJsonBytes();
      if (!context.mounted) return;
      // Close busy dialog before the system save picker appears.
      _safePopBusy(context);
      busyOpen = false;
      final saved = await BackupFileGateway().saveJsonBytes(
        bytes: bytes,
        fileName: 'dun_dun_dun_backup.json',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(saved ? '数据已导出（UTF-8）' : '已取消导出')));
    } on PlatformException catch (error) {
      if (context.mounted) {
        if (busyOpen) _safePopBusy(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：${error.message ?? error.code}')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        if (busyOpen) _safePopBusy(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败：$error')));
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      // Prefer system file picker for large backups. No paste step required.
      final bytes = await BackupFileGateway().pickJsonBytes();
      if (bytes == null) {
        // User canceled.
        return;
      }
      if (!context.mounted) return;
      await _importBytes(context, ref, bytes);
    } on PlatformException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：${error.message ?? error.code}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('导入失败，数据未改变')));
      }
    }
  }

  Future<void> _importBytes(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
  ) async {
    _showBusyDialog(context, '正在导入，请稍候…');
    try {
      final count = await BackupService(
        ref.read(appDatabaseProvider),
        persistPreImport: true,
      ).importJson(BackupService.decodeBackupBytes(bytes));
      ref
        ..invalidate(settingsValuesProvider)
        ..invalidate(storageExpiryPolicyProvider)
        ..invalidate(homeInventorySummaryProvider)
        ..invalidate(homeEarliestRecordProvider)
        ..invalidate(homeRecordsProvider)
        ..invalidate(inventoryRecordsProvider)
        ..invalidate(statisticsSummaryProvider)
        ..invalidate(statisticsRecordsProvider)
        ..invalidate(intakeFoodTagsProvider);
      if (context.mounted) {
        _safePopBusy(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已合并 $count 项数据')));
      }
    } on BackupFailure catch (error) {
      if (context.mounted) {
        _safePopBusy(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_backupFailureMessage(error))));
      }
    } catch (error) {
      if (context.mounted) {
        _safePopBusy(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导入失败：$error')));
      }
    }
  }

  void _showBusyDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _safePopBusy(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  String _backupFailureMessage(BackupFailure failure) {
    return switch (failure.code) {
      'unsupported_schema' => '备份文件版本不受支持',
      'invalid_json' => '备份文件已损坏或不是有效 JSON',
      final code when code.startsWith('invalid_enum_') => '备份文件包含无法识别的状态值',
      _ => '导入失败，数据未改变',
    };
  }
}

class _ExpirySettingsDialog extends StatefulWidget {
  const _ExpirySettingsDialog({required this.current});
  final ExpiryPolicy current;

  @override
  State<_ExpirySettingsDialog> createState() => _ExpirySettingsDialogState();
}

class _ExpirySettingsDialogState extends State<_ExpirySettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _refrigerated = TextEditingController(
    text: '${widget.current.refrigeratedDays}',
  );
  late final _frozen = TextEditingController(
    text: '${widget.current.frozenMonths}',
  );
  late final _bestUse = TextEditingController(
    text: '${widget.current.frozenBestUseMonths}',
  );

  @override
  void dispose() {
    _refrigerated.dispose();
    _frozen.dispose();
    _bestUse.dispose();
    super.dispose();
  }

  Widget _field(
    String label,
    String unit,
    TextEditingController controller,
    int max, {
    bool bestUse = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, suffixText: unit),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (text) {
          final value = int.tryParse(text ?? '');
          if (value == null || value < 1 || value > max) {
            return '请输入 1～$max 的整数';
          }
          if (bestUse && value > (int.tryParse(_frozen.text) ?? 0)) {
            return '最佳使用期不能超过冷冻保质期';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('保质期设置'),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('冷藏保质期', '天', _refrigerated, 365),
            _field('冷冻保质期', '个月', _frozen, 120),
            _field('冷冻最佳使用期', '个月', _bestUse, 120, bestUse: true),
            const Text('按入库时间计算；用于新入库及重新编辑的记录，已有记录保留原期限。'),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            ExpiryPolicy(
              refrigeratedDays: int.parse(_refrigerated.text),
              frozenMonths: int.parse(_frozen.text),
              frozenBestUseMonths: int.parse(_bestUse.text),
            ),
          );
        },
        child: const Text('保存'),
      ),
    ],
  );
}
