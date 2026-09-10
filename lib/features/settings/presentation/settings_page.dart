import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = 'settings';

  @override
  Widget build(BuildContext context) {
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
            const ListTile(
              enabled: false,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(Icons.restaurant_outlined),
              title: Text('常用食物'),
              subtitle: Text('将在入库功能完成后开放'),
            ),
            const ListTile(
              enabled: false,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(Icons.notifications_outlined),
              title: Text('到期提醒'),
              subtitle: Text('将在通知功能完成后开放'),
            ),
            const ListTile(
              enabled: false,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(Icons.archive_outlined),
              title: Text('数据备份与恢复'),
              subtitle: Text('将在备份功能完成后开放'),
            ),
          ],
        ),
      ),
    );
  }
}
