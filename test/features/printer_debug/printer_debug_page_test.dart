import 'dart:async';

import 'package:breast_milk/features/printer_debug/presentation/printer_debug_page.dart';
import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_models.dart';
import 'package:breast_milk/platform/printer/printer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('授权后显示已配对打印机', (tester) async {
    final gateway = _FakePrinterGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [printerGatewayProvider.overrideWithValue(gateway)],
        child: const MaterialApp(home: PrinterDebugPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('等待蓝牙权限'), findsOneWidget);
    await tester.tap(find.text('授权'));
    await tester.pumpAndSettle();

    expect(find.text('P203A'), findsOneWidget);
    expect(find.textContaining('已配对'), findsOneWidget);
    expect(gateway.permissionRequests, 1);
  });
}

class _FakePrinterGateway implements PrinterGateway {
  final _events = StreamController<PrinterEvent>.broadcast();
  var granted = false;
  var permissionRequests = 0;

  @override
  Stream<PrinterEvent> get events => _events.stream;

  @override
  Future<bool> hasPermissions() async => granted;

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    granted = true;
    return true;
  }

  @override
  Future<List<PrinterDevice>> getBondedDevices() async => const [
    PrinterDevice(name: 'P203A', address: '00:11:22:33:44:55', isBonded: true),
  ];

  @override
  Future<PrinterStatus> getStatus() async =>
      const PrinterStatus(bluetoothState: 'enabled', isConnected: false);

  @override
  Future<void> connect(String address) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> printMilkLabel(MilkLabelData label) async {}

  @override
  Future<void> printTestLabel() async {}

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}
}
