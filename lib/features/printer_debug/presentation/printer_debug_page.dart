import 'dart:async';

import 'package:breast_milk/platform/printer/printer_gateway.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/platform/printer/printer_models.dart';
import 'package:breast_milk/platform/printer/printer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrinterDebugPage extends ConsumerStatefulWidget {
  const PrinterDebugPage({super.key});

  static const routeName = 'printer-debug';

  @override
  ConsumerState<PrinterDebugPage> createState() => _PrinterDebugPageState();
}

class _PrinterDebugPageState extends ConsumerState<PrinterDebugPage> {
  final Map<String, PrinterDevice> _devices = {};
  late final PrinterGateway _gateway;
  StreamSubscription<PrinterEvent>? _subscription;
  PrinterStatus? _status;
  bool _hasPermissions = false;
  bool _isBusy = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _gateway = ref.read(printerGatewayProvider);
    _subscription = _gateway.events.listen(
      _onEvent,
      onError: (Object error) => _showError(error),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    unawaited(_gateway.stopScan().catchError((_) {}));
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _refresh() => _run(_load);

  Future<void> _load() async {
    final hasPermissions = await _gateway.hasPermissions();
    final devices = hasPermissions
        ? await _gateway.getBondedDevices()
        : const <PrinterDevice>[];
    final status = hasPermissions ? await _gateway.getStatus() : null;
    if (!mounted) return;
    setState(() {
      _hasPermissions = hasPermissions;
      _status = status;
      for (final device in devices) {
        _devices[device.address] = device;
      }
    });
  }

  Future<void> _requestPermissions() => _run(() async {
    final granted = await _gateway.requestPermissions();
    if (!granted) {
      throw const PrinterFailure('permissions_required');
    }
    await _load();
  });

  Future<void> _toggleScan() => _run(() async {
    if (_isScanning) {
      await _gateway.stopScan();
      if (mounted) setState(() => _isScanning = false);
    } else {
      await _gateway.startScan();
      if (mounted) setState(() => _isScanning = true);
    }
  });

  Future<void> _connect(PrinterDevice device) => _run(() async {
    await _gateway.connect(device.address);
    final status = await _gateway.getStatus();
    if (mounted) setState(() => _status = status);
  });

  Future<void> _disconnect() => _run(() async {
    await _gateway.disconnect();
    final status = await _gateway.getStatus();
    if (mounted) setState(() => _status = status);
  });

  Future<void> _printTestLabel() => _run(() async {
    await _gateway.printTestLabel();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('测试标签已发送')));
    }
  });

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _onEvent(PrinterEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case PrinterEventType.device:
        final device = event.device;
        if (device != null) {
          setState(() => _devices[device.address] = device);
        }
      case PrinterEventType.scan:
        if (event.state == 'finished' || event.state == 'stopped') {
          setState(() => _isScanning = false);
        }
      case PrinterEventType.connection:
        unawaited(_refresh());
      case PrinterEventType.print:
      case PrinterEventType.unknown:
        break;
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = error is PrinterFailure
        ? error.displayMessage
        : '操作失败，请稍后重试';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final devices = _devices.values.toList()
      ..sort((a, b) {
        if (a.isBonded != b.isBonded) return a.isBonded ? -1 : 1;
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('P203A 打印机')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _StatusSection(
              hasPermissions: _hasPermissions,
              status: status,
              isBusy: _isBusy,
              onRequestPermissions: _requestPermissions,
              onDisconnect: _disconnect,
            ),
            const Divider(height: 32),
            Row(
              children: [
                Text('蓝牙设备', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: _isBusy || !_hasPermissions ? null : _refresh,
                  tooltip: '刷新已配对设备',
                  icon: const Icon(Icons.refresh),
                ),
                IconButton.filledTonal(
                  onPressed: _isBusy || !_hasPermissions ? null : _toggleScan,
                  tooltip: _isScanning ? '停止扫描' : '扫描设备',
                  icon: Icon(
                    _isScanning ? Icons.stop : Icons.bluetooth_searching,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_hasPermissions)
              const Text('授予蓝牙权限后可读取已配对设备并扫描打印机。')
            else if (devices.isEmpty)
              const Text('没有发现设备，请确认打印机已开机并处于可发现状态。')
            else
              for (final device in devices)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    device.isBonded
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                  ),
                  title: Text(device.name),
                  subtitle: Text(
                    '${device.address}${device.isBonded ? ' · 已配对' : ''}',
                  ),
                  trailing: IconButton(
                    onPressed: _isBusy ? null : () => _connect(device),
                    tooltip: '连接',
                    icon: const Icon(Icons.link),
                  ),
                ),
            const Divider(height: 32),
            Text('标签校准', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('40 × 30 mm · TSPL · 左侧二维码'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isBusy || status?.isConnected != true
                  ? null
                  : _printTestLabel,
              icon: const Icon(Icons.print),
              label: const Text('打印测试标签'),
            ),
            if (_isBusy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.hasPermissions,
    required this.status,
    required this.isBusy,
    required this.onRequestPermissions,
    required this.onDisconnect,
  });

  final bool hasPermissions;
  final PrinterStatus? status;
  final bool isBusy;
  final VoidCallback onRequestPermissions;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final isConnected = status?.isConnected == true;
    final statusText = !hasPermissions
        ? '等待蓝牙权限'
        : isConnected
        ? '已连接 ${status?.address ?? ''}'
        : switch (status?.bluetoothState) {
            'disabled' => '蓝牙未开启',
            'unavailable' => '蓝牙不可用',
            _ => '未连接',
          };

    return Row(
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.info_outline,
          color: isConnected
              ? Colors.teal
              : Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(statusText)),
        if (!hasPermissions)
          FilledButton(
            onPressed: isBusy ? null : onRequestPermissions,
            child: const Text('授权'),
          )
        else if (isConnected)
          TextButton(
            onPressed: isBusy ? null : onDisconnect,
            child: const Text('断开'),
          ),
      ],
    );
  }
}
