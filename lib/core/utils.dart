import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/routes/router.dart';

final snackBarProvider = Provider.family((ref, String msg) {
  final messengerState = ref.read(scaffoldMessengerKeyProvider).currentState;
  messengerState?.showSnackBar(SnackBar(content: Text(msg)));
});

/// catchError専用
final showDialogProvider = Provider((ref) {
  bool isDialogShowing = false;
  return (e) async {
    // showDialogが既に表示されている場合、何もしない
    if (isDialogShowing) return;
    isDialogShowing = true;
    // 閉じられるのを待つ
    await showDialog(
      context: ref.read(rootNavigatorKeyProvider).currentContext!,
      builder: (_) => ErrorDialog(error: e),
    );
    // ダイアログが閉じられたときにフラグをリセット
    isDialogShowing = false;
  };
});
