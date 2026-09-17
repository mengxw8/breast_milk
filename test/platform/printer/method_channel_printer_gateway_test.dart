import 'package:breast_milk/platform/printer/method_channel_printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('printer-test');
  final calls = <MethodCall>[];
  late MethodChannelPrinterGateway gateway;

  setUp(() {
    calls.clear();
    gateway = MethodChannelPrinterGateway(methodChannel: channel);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('解析配对设备和打印机状态', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'getBondedDevices' => [
              {'name': 'P203A', 'address': '00:11:22:33:44:55', 'bonded': true},
            ],
            'getStatus' => {
              'bluetooth': 'enabled',
              'connected': true,
              'address': '00:11:22:33:44:55',
            },
            _ => null,
          };
        });

    final devices = await gateway.getBondedDevices();
    final status = await gateway.getStatus();

    expect(devices.single.name, 'P203A');
    expect(devices.single.isBonded, isTrue);
    expect(status.isConnected, isTrue);
    expect(status.address, '00:11:22:33:44:55');
    expect(calls.map((call) => call.method), ['getBondedDevices', 'getStatus']);
  });

  test('正式标签按稳定结构发送给原生模块', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
    const label = MilkLabelData(
      id: '2026091011570101',
      date: '2026-09-10',
      time: '11:57',
      amount: '120 mL',
      storage: '冷冻 -21℃',
      food: '鸡蛋',
    );

    await gateway.printMilkLabel(label);

    expect(calls.single.method, 'printMilkLabel');
    expect(
      (calls.single.arguments as Map<Object?, Object?>)['label'],
      label.toMap(),
    );
  });

  test('平台错误转换为稳定打印错误', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'not_connected');
        });

    await expectLater(
      gateway.printTestLabel(),
      throwsA(
        isA<PrinterFailure>().having(
          (failure) => failure.code,
          'code',
          'not_connected',
        ),
      ),
    );
  });
}
