# breast_milk

A new Flutter project.

## 开发与验收

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

首次使用请在 Android 13 中授予相机、通知和蓝牙权限，在系统蓝牙设置中配对 Xprinter P203A，再从“设置 > 蓝牙打印机”连接并打印测试标签。标签校准以 40 x 30 mm 为目标，打印失败不会删除已保存的入库记录。

设置页支持本地通知开关、每日提醒时间，以及包含记录、状态事件和食物标签的 JSON 导出与合并导入。备份文件含个人信息，请妥善保管。