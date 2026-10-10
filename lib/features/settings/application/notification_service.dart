import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;

  bool _available = true;

  Future<void> initialize() async {
    _available = true;
    tz_data.initializeTimeZones();
    // A missing/unknown native ID still uses the device clock offset, not UTC.
    tz.setLocalLocation(_fixedOffset(DateTime.now().timeZoneOffset));
    try {
      final name = await const MethodChannel('cn.mengxw.breast_milk/system')
          .invokeMethod<String>('timezone');
      if (name != null && name.isNotEmpty) {
        tz.setLocalLocation(_resolveLocation(name));
      }
    } on MissingPluginException {
      // The system channel is Android-only.
    } on PlatformException {
      // Retain the device offset if the native timezone lookup fails.
    } on tz.LocationNotFoundException {
      // An unknown platform timezone should not prevent notifications.
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
          macOS: DarwinInitializationSettings(),
          linux: LinuxInitializationSettings(defaultActionName: '打开'),
          windows: WindowsInitializationSettings(
            appName: '吨吨吨',
            appUserModelId: 'cn.mengxw.breast_milk',
            guid: '31c85167-19d6-4dd1-9706-04613b87fbb1',
          ),
        ),
      );
    } on MissingPluginException {
      _available = false;
    }
  }

  tz.Location _fixedOffset(Duration offset) => tz.Location(
    'device-local',
    const [],
    const [],
    [tz.TimeZone(offset, isDst: false, abbreviation: 'local')],
  );

  tz.Location _resolveLocation(String name) {
    if (name == 'Asia/Calcutta') name = 'Asia/Kolkata';
    final match = RegExp(r'^GMT([+-])(\d{2}):(\d{2})$').firstMatch(name);
    if (match != null) {
      final hours = int.parse(match[2]!);
      final minutes = int.parse(match[3]!);
      if (hours <= 14 && minutes < 60 && (hours < 14 || minutes == 0)) {
        return _fixedOffset(
          Duration(
            minutes: (hours * 60 + minutes) * (match[1] == '-' ? -1 : 1),
          ),
        );
      }
    }
    return tz.getLocation(name);
  }

  Future<void> requestPermission() async {
    if (!_available) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    int riskCount = 0,
    int totalMl = 0,
  }) async {
    if (!_available) return;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: 1,
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_risk',
          '到期提醒',
          channelDescription: '母乳库存临期风险提醒',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: '吨吨吨库存提醒',
      body: riskCount > 0
          ? '有 $riskCount 袋母乳临近期限，共 $totalMl mL，请及时处理。'
          : '当前没有临期母乳记录。',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() async {
    if (_available) await _plugin.cancel(id: 1);
  }
}
