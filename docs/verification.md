# 验证与发布签名

在项目根目录执行 `./scripts/check.ps1`：依次运行 Flutter analyze、全部 Flutter 测试及 Android lint（包含应用 Kotlin）。Android 检查需要 Java 17 或以上及 Android SDK。第三方插件的单元测试不属于本项目检查范围，lint 初始化脚本关闭它们的测试 variant，避免 Windows 跨盘符和 Robolectric 依赖问题；生产代码仍接受检查。手动检查时，在 `android/` 目录运行 `./gradlew.bat :app:lintDebug --init-script ../scripts/android-lint.init.gradle`。

发布前将 `android/key.properties.example` 复制为 `android/key.properties`，填写独立发布密钥的路径、alias 和密码。storeFile 相对于 android 目录，也可填写绝对路径。密钥文件和 key.properties 已加入忽略规则。未配置时 release 构建明确失败，debug 和 lint 不需要发布密钥。

首次发布且没有现成密钥时，在项目根目录运行 `./scripts/setup-release-signing.ps1`（需要 Java 的 `keytool` 在 PATH 中），自动生成独立 RSA 发布密钥和随机密码，并写入本机 `android/key.properties`。随后运行 `flutter build apk --release`，安装包位于 `build/app/outputs/flutter-apk/app-release.apk`。脚本拒绝覆盖已有签名文件。请安全备份 `android/release-keystore.jks` 和 `android/key.properties`；已发布应用必须继续使用原发布密钥，不要重新生成。

### 覆盖安装时签名不一致

`INSTALL_FAILED_UPDATE_INCOMPATIBLE` 表示手机中同包名应用的签名与待安装 APK 不同，`adb install -r` 也不能绕过这一限制。先用 Android SDK Build Tools 中的 `apksigner verify --print-certs` 检查旧 APK 的证书，再与原密钥比对。保留数据的更新必须继续使用原签名。

若旧应用使用本机 `debug.keystore`，且已核验证书匹配，可将 release APK 的副本重新签成仅用于本机测试的更新包（将 Build Tools 加入 PATH 后，在项目根目录执行）：

```powershell
apksigner sign --ks "$env:USERPROFILE\.android\debug.keystore" --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out build/app/outputs/flutter-apk/app-release-local-update.apk build/app/outputs/flutter-apk/app-release.apk
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release-local-update.apk
adb install -r build/app/outputs/flutter-apk/app-release-local-update.apk
```

这个副本仍是 debug 签名，不用于正式分发，原 `app-release.apk` 保持独立发布签名。需要在设备上切换到新发布签名时，先从应用设置导出并核验数据备份，再卸载旧应用、安装正式包并导入备份；卸载会清除应用数据，提醒设置需要重新配置。

回归测试检查：320px 库存卡片在 1.0 / 1.3 / 2.0 倍字号下全部待打印文案的几何边界；动态过期详情及丢弃动作；深浅主题选中带与折线至少 3:1 的对比度；未知时区和缺失插件降级；坏备份及旧版文件；到期/零点/前台刷新与后台停止计时；20 条带标签记录的列表和待打印查询各只执行 2 次 SELECT。


真机通知回归（Android）：安装 debug/release 包后，在「设置 → 到期提醒」开启通知，把提醒时间设为当前时间后 2 分钟，锁屏等待通知出现；随后重启设备，确认同一提醒仍会在下一次设定时间触发。若系统要求电池优化或自启动权限，按设备提示允许。该检查用于验证 AlarmManager、通知权限及重启后的重新排程，自动化 widget 测试无法覆盖。
