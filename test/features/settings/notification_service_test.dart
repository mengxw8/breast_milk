import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:breast_milk/features/settings/application/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const system = MethodChannel('cn.mengxw.breast_milk/system');
  const notifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(system, null);
    messenger.setMockMethodCallHandler(notifications, null);
  });
  test('服务 provider 在同一容器内复用实例', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(notificationServiceProvider),
      same(container.read(notificationServiceProvider)),
    );
  });

  for (final name in [
    'Asia/Shanghai',
    'GMT+08:00',
    'Asia/Calcutta',
    'Etc/Unknown',
    'missing',
    'platform',
  ]) {
    test('初始化降级且通知插件仍能初始化：$name', () async {
      var initialized = false;
      messenger.setMockMethodCallHandler(system, (_) async {
        if (name == 'missing') throw MissingPluginException();
        if (name == 'platform') throw PlatformException(code: 'unavailable');
        return name;
      });
      messenger.setMockMethodCallHandler(notifications, (call) async {
        if (call.method == 'initialize') initialized = true;
        return true;
      });
      await NotificationService().initialize();
      expect(initialized, isTrue);
      if (name == 'GMT+08:00' || name == 'Asia/Shanghai') {
        expect(
          tz.TZDateTime.now(tz.local).timeZoneOffset,
          const Duration(hours: 8),
        );
      }
      if (name == 'Asia/Calcutta') expect(tz.local.name, 'Asia/Kolkata');
    });
  }
  test('重复和并发初始化只解析一次时区并初始化一次插件', () async {
    var timezoneCalls = 0;
    var pluginCalls = 0;
    messenger.setMockMethodCallHandler(system, (_) async {
      timezoneCalls++;
      return 'Asia/Shanghai';
    });
    messenger.setMockMethodCallHandler(notifications, (call) async {
      if (call.method == 'initialize') pluginCalls++;
      return true;
    });
    final service = NotificationService();
    await Future.wait(List.generate(8, (_) => service.initialize()));
    await service.initialize();
    expect(timezoneCalls, 1);
    expect(pluginCalls, 1);
  });

  test('初始化失败允许后续重试', () async {
    var attempts = 0;
    messenger.setMockMethodCallHandler(system, (_) async => 'Asia/Shanghai');
    messenger.setMockMethodCallHandler(notifications, (call) async {
      if (call.method == 'initialize' && ++attempts == 1) {
        throw PlatformException(code: 'temporary_failure');
      }
      return true;
    });
    final service = NotificationService();
    await expectLater(service.initialize(), throwsA(isA<PlatformException>()));
    await service.initialize();
    await service.initialize();
    expect(attempts, 2);
  });

  test('相同每日提醒不重复安排，风险变化和取消后会重新安排', () async {
    var schedules = 0;
    messenger.setMockMethodCallHandler(system, (_) async => 'Asia/Shanghai');
    messenger.setMockMethodCallHandler(notifications, (call) async {
      if (call.method == 'zonedSchedule') schedules++;
      return true;
    });
    final service = NotificationService();
    await service.initialize();
    await Future.wait(
      List.generate(5, (_) => service.scheduleDaily(hour: 9, minute: 0)),
    );
    expect(schedules, 1);
    await service.scheduleDaily(hour: 9, minute: 0, riskCount: 1, totalMl: 100);
    expect(schedules, 2);
    await service.cancel();
    await service.scheduleDaily(hour: 9, minute: 0, riskCount: 1, totalMl: 100);
    expect(schedules, 3);
  });

  test('通知插件本身缺失时安全降级', () async {
    messenger.setMockMethodCallHandler(system, (_) async => 'Asia/Shanghai');
    final service = NotificationService();
    await service.initialize();
    await service.requestPermission();
    await service.scheduleDaily(hour: 9, minute: 0);
    await service.cancel();
  });
}
