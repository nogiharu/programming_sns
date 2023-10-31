// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncNotifierEX<T> on AsyncNotifier<T> {
  /// state更新の際にエラーだった場合AysncValue.errorから戻す
  Future<void> futureGuard(Future<T> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = AsyncLoading<T>();

    // await Future.delayed(const Duration(seconds: 3));
    state = await AsyncValue.guard<T>(futureFunction);
    if (state.hasError) {
      // いきなり「state = prevState」をするとダイアログが出ないため,awaitしたら同期するためしない
      Future.delayed(const Duration(seconds: 1), () async => state = prevState);
    }
  }

  /// 予期せぬエラーだあ(T ^ T) 再立ち上げしてね(>_<)
  exceptionMessage(Object? e) {
    String message = '''
    予期せぬエラーだあ(T ^ T)
    再立ち上げしてね(>_<)
    ''';
    if (e is AppwriteException) {
      message = '${e.code}\n$message';
    }
    throw message;
  }
}
