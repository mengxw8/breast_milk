import 'dart:typed_data';

import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/settings/application/backup_service.dart';
import 'package:breast_milk/features/settings/application/settings_store.dart';
import 'package:breast_milk/features/settings/application/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
                      final service = NotificationService();
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

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final parts = current.split(':');
    final picked = await showTimePicker(
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
      final service = NotificationService();
      await service.initialize();
      await service.scheduleDaily(hour: picked.hour, minute: picked.minute);
    }
    ref.invalidate(settingsValuesProvider);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final json = await BackupService(ref.read(appDatabaseProvider))
          .exportJson();
      final path = await FilePicker.saveFile(
        dialogTitle: '导出母乳数据',
        fileName: 'dun_dun_dun_backup.json',
        bytes: Uint8List.fromList(json.codeUnits),
      );
      if (context.mounted && path != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('数据已导出')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('导出失败')));
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return;
      final bytes = await files.first.readAsBytes();
      final count = await BackupService(
        ref.read(appDatabaseProvider),
        persistPreImport: true,
      ).importJson(String.fromCharCodes(bytes));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已合并 $count 项数据')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('导入失败，数据未改变')));
      }
    }
  }
}
