import 'package:breast_milk/app/app_shell.dart';
import 'package:breast_milk/app/theme/app_theme.dart';
import 'package:breast_milk/data/database/database_providers.dart';
import 'package:breast_milk/features/home/presentation/home_page.dart';
import 'package:breast_milk/features/inventory/presentation/inventory_page.dart';
import 'package:breast_milk/platform/printer/printer_providers.dart';
import 'package:breast_milk/domain/models/milk_enums.dart';
import 'package:breast_milk/domain/models/milk_record.dart';
import 'package:breast_milk/domain/repositories/milk_repository.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  static const routeName = 'scanner';
  static const branchIndex = 2;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  final _scannerController = MobileScannerController(autoStart: false);
  final _manualController = TextEditingController();
  String? _lastCode;
  bool _handling = false;
  String? _message;
  bool _expiredAlert = false;
  bool _scannerActive = false;
  bool _appResumed = true;
  int _scannerStateRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appResumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active =
        (ActiveBranchScope.maybeIndexOf(context) ?? ScannerPage.branchIndex) ==
        ScannerPage.branchIndex;
    if (active == _scannerActive) return;
    _scannerActive = active;
    _scheduleScannerState(active && _appResumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerActive = false;
    _scannerStateRevision++;
    unawaited(_scannerController.dispose());
    _manualController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _scheduleScannerState(_scannerActive && _appResumed);
  }

  void _scheduleScannerState(bool shouldRun) {
    final revision = ++_scannerStateRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || revision != _scannerStateRevision) return;
      if (shouldRun && _scannerActive && _appResumed) {
        await _scannerController.start();
        if (mounted && !_scannerActive) await _scannerController.stop();
      } else {
        await _scannerController.stop();
      }
    });
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _scannerController,
                        builder: (context, state, child) {
                          final torchOn = state.torchState == TorchState.on;
                          final available =
                              state.isRunning &&
                              state.torchState != TorchState.unavailable;
                          return Material(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: torchOn ? '关闭闪光灯' : '打开闪光灯',
                              onPressed: available
                                  ? _scannerController.toggleTorch
                                  : null,
                              icon: Icon(
                                torchOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: available
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message ?? '对准标签二维码',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _expiredAlert ? AppTheme.amber : null,
                fontWeight: _expiredAlert ? FontWeight.w700 : null,
              ),
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
    if (!_scannerActive || !_appResumed || _handling) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw != _lastCode) {
        _lastCode = raw;
        SystemSound.play(SystemSoundType.click);
        unawaited(ref.read(printerGatewayProvider).playScanBeep());
        _handleCode(raw);
        return;
      }
    }
  }

  Future<void> _handleCode(String raw) async {
    final code = raw.trim();
    if (!RegExp(r'^\d{16}$').hasMatch(code)) {
      setState(() {
        _expiredAlert = false;
        _message = '编号必须是 16 位纯数字';
      });
      return;
    }
    setState(() {
      _handling = true;
      _expiredAlert = false;
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
      if (_isExpired(record)) {
        await _warnExpired(record);
        return;
      }
      await _confirmCheckout(record);
    } catch (_) {
      if (mounted) {
        setState(() {
          _expiredAlert = false;
          _message = '查询失败，请重试';
        });
      }
    } finally {
      if (mounted) setState(() => _handling = false);
    }
  }

  bool _isExpired(MilkRecord record) {
    return record.status == MilkStatus.expired ||
        record.isExpiredAt(DateTime.now().toUtc());
  }

  Future<void> _warnExpired(MilkRecord record) async {
    final expires = DateFormat('M月d日 HH:mm')
        .format(record.expiresAtUtc.toLocal());
    setState(() {
      _expiredAlert = true;
      _message = '该袋已过期，不能出库';
    });
    await showDialog<void>(
      context: context,
      builder: (context) {
        final warning =
            Theme.of(context).extension<AppSemanticColors>()?.warning ??
            AppTheme.amber;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: warning, size: 36),
          title: const Text('该袋已过期'),
          content: Text(
            '${record.amountMl} mL 已超过最终期限，不能出库。\n'
            '编号：${record.id}\n'
            '最终期限：$expires\n'
            '请改为丢弃，不要当作正常出库。',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
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
      ref.invalidate(inventoryRecordsProvider);
      ref.invalidate(homeInventorySummaryProvider);
      ref.invalidate(homeEarliestRecordProvider);
      ref.invalidate(homeRecordsProvider);
      if (mounted) {
        setState(() {
          _expiredAlert = false;
          _message = '已出库 ${record.id}';
        });
      }
    } on MilkRepositoryFailure catch (error) {
      if (mounted) {
        setState(() {
          _expiredAlert = error.code == 'milk_expired';
          _message = _failureMessage(error.code);
        });
      }
    }
  }

  String _failureMessage(String code) => switch (code) {
    'milk_expired' => '该袋已过期，不能出库',
    'transition_not_allowed' => '当前状态不能出库',
    _ => '出库失败，请重试',
  };
}
