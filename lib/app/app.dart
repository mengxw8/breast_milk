import 'package:breast_milk/app/router.dart';
import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/features/launch/presentation/brand_launch_page.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/settings/application/notification_service.dart';
import 'package:breast_milk/features/settings/application/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class BreastMilkApp extends ConsumerStatefulWidget {
  const BreastMilkApp({super.key});

  @override
  ConsumerState<BreastMilkApp> createState() => _BreastMilkAppState();
}

class _BreastMilkAppState extends ConsumerState<BreastMilkApp> {
  bool _showLaunch = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _restoreNotifications(),
    );
  }

  Future<void> _restoreNotifications() async {
    final values = await SettingsStore(ref.read(appDatabaseProvider)).read();
    if (values['notifications.enabled'] != true || !mounted) return;
    final time = values['notifications.time'] as String? ?? '09:00';
    final parts = time.split(':');
    final service = NotificationService();
    await service.initialize();
    await service.scheduleDaily(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationSyncProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '吨吨吨',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('zh', 'CN')],
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            ?child,
            if (_showLaunch)
              BrandLaunchPage(
                onFinished: () {
                  if (mounted) setState(() => _showLaunch = false);
                },
              ),
          ],
        );
      },
    );
  }
}
