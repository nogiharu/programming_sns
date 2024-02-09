import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// エラーダイアログ
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: AlertDialog(
        title: const Text('エラー'),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
