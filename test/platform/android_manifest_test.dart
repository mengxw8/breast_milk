import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android scheduled notification receivers remain declared', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      ),
    );
    expect(
      manifest,
      contains(
        'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      ),
    );
    for (final action in [
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
      'android.intent.action.QUICKBOOT_POWERON',
      'com.htc.intent.action.QUICKBOOT_POWERON',
    ]) {
      expect(manifest, contains(action));
    }
  });
}
