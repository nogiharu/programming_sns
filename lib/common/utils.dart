import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:appwrite/appwrite.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final snackBarProvider = AutoDisposeProvider((ref) {
  final context = ref.read(shellNavigatorKeyProvider).currentState!.context;
  return ({required String message, VoidCallback? onTap}) {
    showTopSnackBar(
      Overlay.of(context),
      SizedBox(
        height: 50,
        child: CustomSnackBar.success(
          message: message,
          backgroundColor: Colors.amber.shade900,
          iconPositionTop: -20,
        ),
      ),
      onTap: onTap,
    );
  };

  // final messengerState = ref.watch(scaffoldMessengerKeyProvider).currentState;

  // if (messengerState == null) return;
  // double height = MediaQuery.of(messengerState.context).size.height - 100;

  // messengerState.showSnackBar(SnackBar(
  //   behavior: SnackBarBehavior.floating,
  //   content: Text(msg),
  //   margin: EdgeInsets.only(bottom: height, left: 10, right: 10),
  // ));
});

/// エラーダイアログ
/// catchError専用
/// chatScreenでしか使わない
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

exceptionMessage({
  dynamic error,
  String? userId,
  String? loginPassword,
  bool isDefaultError = false,
}) {
  if (isDefaultError) throw error;

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
    print('exceptionMessage：${error.toString()}');
    if (error is AppwriteException &&
        (error.code == 409 ||
            (error.code == 400 && error.toString().contains('general_bad_request')))) {
      throw '既に使われているIDだよ(>_<)';
    }
    throw '''
      ${error is AppwriteException ? 'code：${error.code}' : ''}
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ''';
  }
}
