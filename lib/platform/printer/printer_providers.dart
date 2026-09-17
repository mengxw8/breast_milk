import 'package:breast_milk/platform/printer/method_channel_printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single gateway instance so printer event subscriptions are shared app-wide.
final printerGatewayProvider = Provider<PrinterGateway>(
  (ref) => MethodChannelPrinterGateway(),
);
