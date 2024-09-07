import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
});

customError({
  dynamic error,
  String? userId,
  String? password,
}) {
  if (error == null) {
    //-------------- 認証系 --------------
    if ((userId?.isEmpty ?? false) || (password?.isEmpty ?? false)) {
      throw '入力は必須だよ(>_<)';
    }

    if (userId != null && !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(userId)) {
      throw 'IDに無効な文字が使われてるよ(>_<)';
    }

    if (password != null && password.length < 8) {
      throw 'パスワードは８桁以上で入れてね(>_<)';
    }
  } else {
    debugPrint(error.toString());

    //-------------- AuthException系 --------------
    if (error is AuthException) {
      final isRegistered = error.message.contains('email address has already been registered');
      if (error.statusCode == '422' && isRegistered) throw 'すでに使われているIDだよ(>_<)';

      final isEmailInvalid = error.message.contains('email address: invalid format');
      if (error.statusCode == '420' && isEmailInvalid) throw 'IDに無効な文字が使われてるよ(>_<)';

      final isLoginInvalid = error.message.contains('Invalid login credentials');
      if (error.statusCode == '400' && isLoginInvalid) throw 'このIDの人は存在しないよ(>_<)';

      final isPasswordSame = error.message.contains('different from the old password');
      if (error.statusCode == '422' && isPasswordSame) throw 'パスワードは前のとは別のにしてね(>_<)';
    }

    if (error is! Exception) throw error;
    throw '''
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ${error.toString()}
      ''';
  }
}

/// catchErrorの拡張版
extension FutureEX<T> on Future<T> {
  /// catchErrorの拡張版
  /// error - エラー
  /// isCustomError デフォルトのエラーか
  Future<T> catchErrorEX({isCustomError = true}) {
    return catchError((e) => isCustomError ? customError(error: e) : throw e);
  }
}

/// catchErrorの拡張版
extension StreamEX<T> on Stream<T> {
  /// catchErrorの拡張版
  /// error - エラー
  /// isCustomError デフォルトのエラーか
  Stream<T> handleErrorEX({isCustomError = true}) {
    return handleError((e) => isCustomError ? customError(error: e) : throw e);
  }
}
