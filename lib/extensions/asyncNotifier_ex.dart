// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element

import 'package:flutter_riverpod/flutter_riverpod.dart';

// state更新の際に戻す
extension AsyncNotifierEX<T> on AsyncNotifier<T> {
  Future<void> _futureGuard(Future<T> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = await AsyncValue.guard<T>(futureFunction);
    if (state.hasError) {
      Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    }
  }
}
