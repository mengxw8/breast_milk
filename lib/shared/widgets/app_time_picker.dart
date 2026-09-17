import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App time picker that avoids Material [showTimePicker] input-mode crashes.
///
/// Material TimePicker keeps a fixed minHeight of 216 while Android
/// `adjustResize` shrinks the window under the keyboard, producing
/// non-normalized BoxConstraints and an assert failure.
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _AppTimePickerDialog(initialTime: initialTime),
  );
}

class _AppTimePickerDialog extends StatefulWidget {
  const _AppTimePickerDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_AppTimePickerDialog> createState() => _AppTimePickerDialogState();
}

class _AppTimePickerDialogState extends State<_AppTimePickerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = TextEditingController(
      text: widget.initialTime.hour.toString().padLeft(2, '0'),
    );
    _minuteController = TextEditingController(
      text: widget.initialTime.minute.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final hour = int.parse(_hourController.text);
    final minute = int.parse(_minuteController.text);
    Navigator.of(context).pop(TimeOfDay(hour: hour, minute: minute));
  }

  String? _validateHour(String? value) {
    final hour = int.tryParse(value ?? '');
    if (hour == null || hour < 0 || hour > 23) return '0-23';
    return null;
  }

  String? _validateMinute(String? value) {
    final minute = int.tryParse(value ?? '');
    if (minute == null || minute < 0 || minute > 59) return '0-59';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('选择时间'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hourController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: '时',
                    counterText: '',
                  ),
                  validator: _validateHour,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 28, left: 8, right: 8),
                child: Text(':', style: theme.textTheme.headlineMedium),
              ),
              Expanded(
                child: TextFormField(
                  controller: _minuteController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: '分',
                    counterText: '',
                  ),
                  validator: _validateMinute,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('确定')),
      ],
    );
  }
}
