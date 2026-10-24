import 'package:flutter/material.dart';

import '../tokens.dart';

/// Title + message + right-aligned text buttons (reference 11_list_delete_confirm.png).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? note,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppText.body),
          if (note != null) ...[
            const SizedBox(height: AppSpace.s),
            Text(note, style: AppText.caption),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}

/// Single text field dialog (reference 03_newalbum_dialog.png). [validate]
/// returns an error message, or null when the value is acceptable. Returns
/// the trimmed value, or null when cancelled.
Future<String?> showNameInputDialog(
  BuildContext context, {
  required String title,
  required String? Function(String value) validate,
  String initialValue = '',
  String hint = '',
  int maxLength = 20,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (_) => _NameInputDialog(
      title: title,
      validate: validate,
      initialValue: initialValue,
      hint: hint,
      maxLength: maxLength,
    ),
  );
}

class _NameInputDialog extends StatefulWidget {
  const _NameInputDialog({
    required this.title,
    required this.validate,
    required this.initialValue,
    required this.hint,
    required this.maxLength,
  });

  final String title;
  final String? Function(String value) validate;
  final String initialValue;
  final String hint;
  final int maxLength;

  @override
  State<_NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<_NameInputDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final error = widget.validate(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() => _error = null),
        onSubmitted: (_) => _submit(),
        style: AppText.body,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: _error,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => TextButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}
