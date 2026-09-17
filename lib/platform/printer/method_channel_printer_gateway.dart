import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_models.dart';
import 'package:flutter/services.dart';

class MethodChannelPrinterGateway implements PrinterGateway {
  MethodChannelPrinterGateway({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel = methodChannel ?? const MethodChannel(_methodChannelName),
       _eventChannel = eventChannel ?? const EventChannel(_eventChannelName);

  static const _methodChannelName = 'cn.mengxw.breast_milk/printer';
  static const _eventChannelName = 'cn.mengxw.breast_milk/printer_events';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  // One platform EventChannel subscription shared by all Dart listeners.
  // Multiple receiveBroadcastStream() calls would cancel each other.
  late final Stream<PrinterEvent> _events = _eventChannel
      .receiveBroadcastStream()
      .map((event) => PrinterEvent.fromMap(_asMap(event)))
      .handleError((Object error) => throw _mapError(error))
      .asBroadcastStream();

  @override
  Stream<PrinterEvent> get events => _events;

  @override
  Future<bool> hasPermissions() =>
      _invoke<bool>('hasPermissions').then((value) => value ?? false);

  @override
  Future<bool> requestPermissions() =>
      _invoke<bool>('requestPermissions').then((value) => value ?? false);

  @override
  Future<List<PrinterDevice>> getBondedDevices() async {
    final devices =
        await _invoke<List<Object?>>('getBondedDevices') ?? const [];
    return devices
        .map((device) => PrinterDevice.fromMap(_asMap(device)))
        .toList(growable: false);
  }

  @override
  Future<void> startScan() => _invoke<void>('startScan');

  @override
  Future<void> stopScan() => _invoke<void>('stopScan');

  @override
  Future<void> connect(String address) =>
      _invoke<void>('connect', {'address': address});

  @override
  Future<void> disconnect() => _invoke<void>('disconnect');

  @override
  Future<PrinterStatus> getStatus() async {
    final status = await _invoke<Object?>('getStatus');
    return PrinterStatus.fromMap(_asMap(status));
  }

  @override
  Future<void> playScanBeep() => _invoke<void>('playScanBeep');

  @override
  Future<void> printTestLabel() => _invoke<void>('printTestLabel');

  @override
  Future<void> printMilkLabel(MilkLabelData label) =>
      _invoke<void>('printMilkLabel', {'label': label.toMap()});

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _methodChannel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      throw PrinterFailure(error.code);
    }
  }

  static Map<Object?, Object?> _asMap(Object? value) {
    if (value is Map) return value.cast<Object?, Object?>();
    throw const PrinterFailure('invalid_platform_data');
  }

  static Object _mapError(Object error) {
    if (error is PlatformException) return PrinterFailure(error.code);
    return error;
  }
}
