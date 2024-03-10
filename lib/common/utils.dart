import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:appwrite/appwrite.dart';

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

exceptionMessage({dynamic error, String? userId, String? loginPassword}) {
  //-------------- 認証系 --------------
  if ((userId?.isEmpty ?? false) || (loginPassword?.isEmpty ?? false)) {
    throw '入力は必須だよ(>_<)';
  }

  if (userId != null && !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(userId)) {
    throw 'IDに無効な文字が使われてるよ(>_<)';
  }

  if (loginPassword != null && loginPassword.length < 8) {
    throw 'パスワードは８桁以上で入れてね(>_<)';
  }

  //-------------- API系 --------------
  if (error != null) {
    if (error is AppwriteException && error.code == 409) {
      throw '既に使われているIDだよ(>_<)';
    }
    throw '''
      code：${error is AppwriteException ? '${error.code}' : ''}
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ''';
  }
}
