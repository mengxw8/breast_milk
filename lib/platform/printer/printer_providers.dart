import 'package:breast_milk/platform/printer/method_channel_printer_gateway.dart';
import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final printerGatewayProvider = Provider<PrinterGateway>(
  (ref) => const MethodChannelPrinterGateway(),
);
