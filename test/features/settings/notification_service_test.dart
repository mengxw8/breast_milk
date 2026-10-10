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
  test('通知插件本身缺失时安全降级', () async {
    messenger.setMockMethodCallHandler(system, (_) async => 'Asia/Shanghai');
    final service = NotificationService();
    await service.initialize();
    await service.requestPermission();
    await service.scheduleDaily(hour: 9, minute: 0);
    await service.cancel();
  });
}
