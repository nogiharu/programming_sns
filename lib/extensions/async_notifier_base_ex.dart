// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element, invalid_use_of_internal_member, implementation_imports

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

extension AsyncNotifierBaseEX<T> on AsyncNotifierBase<T> {
  /// state更新の際にエラーだった場合AysncValue.errorから戻す
  Future<void> futureGuard(Future<T> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = AsyncLoading<T>();

    state = await AsyncValue.guard<T>(futureFunction);

    if (state.hasError) {
      // いきなり「state = prevState」をするとダイアログが出ないため,awaitしたら同期するためしない
      Future.delayed(const Duration(milliseconds: 500), () => state = prevState);
    }
  }

  // exceptionMessage({dynamic error, String? loginId, String? loginPassword}) {
  //   //-------------- 認証系 --------------
  //   if ((loginId?.isEmpty ?? false) || (loginPassword?.isEmpty ?? false)) {
  //     throw '入力は必須だよ(>_<)';
  //   }

  //   if (loginId != null && !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(loginId)) {
  //     throw 'IDに無効な文字が使われてるよ(>_<)';
  //   }

  //   if (loginPassword != null && loginPassword.length < 8) {
  //     throw 'パスワードは８桁以上で入れてね(>_<)';
  //   }

  //   //-------------- API系 --------------
  //   if (error != null) {
  //     if (error is AppwriteException && error.code == 409) {
  //       throw '既に使われているIDだよ(>_<)';
  //     }
  //     throw '''
  //     予期せぬエラーだあ(T ^ T)
  //     再立ち上げしてね(>_<)
  //     ${error is AppwriteException ? '${error.code}' : ''}
  //     ''';
  //   }
  // }
}
