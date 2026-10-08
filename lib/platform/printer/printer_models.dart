enum PrinterEventType { device, connection, scan, print, unknown }

class PrinterDevice {
  const PrinterDevice({
    required this.name,
    required this.address,
    required this.isBonded,
    this.rssi,
  });

  factory PrinterDevice.fromMap(Map<Object?, Object?> map) {
    return PrinterDevice(
      name: map['name']?.toString() ?? '未命名设备',
      address: map['address']?.toString() ?? '',
      isBonded: map['bonded'] == true,
      rssi: (map['rssi'] as num?)?.toInt(),
    );
  }

  final String name;
  final String address;
  final bool isBonded;
  final int? rssi;
}

class PrinterStatus {
  const PrinterStatus({
    required this.bluetoothState,
    required this.isConnected,
    this.address,
  });

  factory PrinterStatus.fromMap(Map<Object?, Object?> map) {
    return PrinterStatus(
      bluetoothState: map['bluetooth']?.toString() ?? 'unavailable',
      isConnected: map['connected'] == true,
      address: map['address']?.toString(),
    );
  }

  final String bluetoothState;
  final bool isConnected;
  final String? address;
}

class PrinterEvent {
  const PrinterEvent({
    required this.type,
    this.state,
    this.address,
    this.device,
  });

  factory PrinterEvent.fromMap(Map<Object?, Object?> map) {
    final type = switch (map['type']) {
      'device' => PrinterEventType.device,
      'connection' => PrinterEventType.connection,
      'scan' => PrinterEventType.scan,
      'print' => PrinterEventType.print,
      _ => PrinterEventType.unknown,
    };
    final deviceMap = map['device'];
    return PrinterEvent(
      type: type,
      state: map['state']?.toString(),
      address: map['address']?.toString(),
      device: deviceMap is Map
          ? PrinterDevice.fromMap(deviceMap.cast<Object?, Object?>())
          : null,
    );
  }

  final PrinterEventType type;
  final String? state;
  final String? address;
  final PrinterDevice? device;
}

class MilkLabelData {
  const MilkLabelData({
    required this.id,
    required this.date,
    required this.time,
    required this.amount,
    required this.storage,
    required this.food,
    this.isReprint = false,
  });

  final String id;
  final String date;
  final String time;
  final String amount;
  final String storage;
  final String food;
  final bool isReprint;

  Map<String, String> toMap() => {
    'id': id,
    'date': date,
    'time': time,
    'amount': amount,
    'storage': storage,
    'food': food,
    'reprint': isReprint.toString(),
  };
}

class PrinterFailure implements Exception {
  const PrinterFailure(this.code);

  final String code;

  String get displayMessage => switch (code) {
    'permissions_required' => '需要蓝牙权限',
    'permission_request_in_progress' => '正在请求蓝牙权限',
    'bluetooth_unavailable' => '此设备不支持蓝牙',
    'bluetooth_disabled' => '请先开启蓝牙',
    'bluetooth_enable_cancelled' => '已取消开启蓝牙，可点击开启蓝牙重试',
    'bluetooth_enable_failed' => '无法打开蓝牙开启弹窗，请在系统设置中开启蓝牙',
    'scan_start_failed' => '无法开始扫描',
    'invalid_address' => '蓝牙设备地址无效',
    'connect_failed' => '打印机连接失败',
    'connection_interrupted' => '打印机连接已断开',
    'not_connected' => '请先连接打印机',
    'invalid_label' => '标签数据不完整',
    'print_failed' || 'send_failed' => '标签发送失败',
    _ => '打印机暂时不可用',
  };

  @override
  String toString() => 'PrinterFailure($code)';
}
