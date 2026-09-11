import 'package:breast_milk/platform/printer/printer_models.dart';

abstract interface class PrinterGateway {
  Stream<PrinterEvent> get events;

  Future<bool> hasPermissions();

  Future<bool> requestPermissions();

  Future<List<PrinterDevice>> getBondedDevices();

  Future<void> startScan();

  Future<void> stopScan();

  Future<void> connect(String address);

  Future<void> disconnect();

  Future<PrinterStatus> getStatus();

  Future<void> playScanBeep();

  Future<void> printTestLabel();

  Future<void> printMilkLabel(MilkLabelData label);
}
