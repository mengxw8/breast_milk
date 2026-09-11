import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  static const routeName = 'scanner';

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final _manualController = TextEditingController();
  String? _lastCode;
  bool _handling = false;
  String? _message;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码出库'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MobileScanner(onDetect: _onDetect),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message ?? '对准标签二维码',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: const InputDecoration(
                labelText: '无法扫码？输入 16 位编号',
                prefixIcon: Icon(Icons.keyboard_outlined),
              ),
            ),
            FilledButton.icon(
              onPressed: _handling
                  ? null
                  : () => _handleCode(_manualController.text),
              icon: const Icon(Icons.search_rounded),
              label: const Text('查询编号'),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handling) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw != _lastCode) {
        _lastCode = raw;
        SystemSound.play(SystemSoundType.click);
        _handleCode(raw);
        return;
      }
    }
  }

  Future<void> _handleCode(String raw) async {
    final code = raw.trim();
    if (!RegExp(r'^\d{16}$').hasMatch(code)) {
      setState(() => _message = '编号必须是 16 位纯数字');
      return;
    }
    setState(() {
      _handling = true;
      _message = '正在查询 $code';
    });
    try {
      final record = await ref.read(milkRepositoryProvider).findById(code);
      if (!mounted) return;
      if (record == null) {
        setState(() => _message = '未找到该编号');
        return;
      }
      if (record.status == MilkStatus.checkedOut) {
        setState(() => _message = '该袋已出库');
        return;
      }
      if (record.status == MilkStatus.discarded) {
        setState(() => _message = '该袋已丢弃');
        return;
      }
      await _confirmCheckout(record);
    } catch (_) {
      if (mounted) setState(() => _message = '查询失败，请重试');
    } finally {
      if (mounted) setState(() => _handling = false);
    }
  }

  Future<void> _confirmCheckout(MilkRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认整袋出库'),
        content: Text('${record.amountMl} mL\n编号：${record.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认出库'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(milkRepositoryProvider)
          .transition(
            TransitionMilkRecordCommand(
              id: record.id,
              action: MilkAction.checkOut,
              occurredAtUtc: DateTime.now().toUtc(),
            ),
          );
      ref.invalidate(homeInventorySummaryProvider);
      ref.invalidate(homeEarliestRecordProvider);
      ref.invalidate(homeRecordsProvider);
      if (mounted) setState(() => _message = '已出库 ${record.id}');
    } on MilkRepositoryFailure catch (error) {
      if (mounted) setState(() => _message = _failureMessage(error.code));
    }
  }

  String _failureMessage(String code) => switch (code) {
    'milk_expired' => '该袋已过期，不能出库',
    'transition_not_allowed' => '当前状态不能出库',
    _ => '出库失败，请重试',
  };
}
