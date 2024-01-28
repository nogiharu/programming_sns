// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element, invalid_use_of_internal_member, implementation_imports

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

extension AsyncNotifierBaseEX<T> on AsyncNotifierBase<T> {
  /// state更新の際にエラーだった場合、stateがAysncErrorのままになるため戻す
  Future<T> futureGuard(Future<T> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = AsyncLoading<T>();

    state = await AsyncValue.guard<T>(futureFunction);

    if (state.hasError) {
      // いきなり「state = prevState」をするとwatchEXのダイアログが出ないため,タイミングをずらす
      Future.delayed(const Duration(milliseconds: 300), () => state = prevState);
    }
    return state.value!;
  }
}
