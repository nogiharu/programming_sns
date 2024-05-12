// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element, invalid_use_of_internal_member, implementation_imports

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:riverpod/src/async_notifier.dart';

// extension AsyncNotifierBaseEX<T> on AsyncNotifierBase<T> {
//   /// - state更新の際にエラーだった場合、stateがAysncErrorのままになるため戻す
//   /// - isLoading:　AsyncLoading 状態にするかどうか
//   /// - isCustomError: カスタムエラーを返すかどうか
//   /// - isStateOnly: 値は更新せず状態だけ更新するか
//   Future<T> futureGuard(
//     Future<T> Function() futureFunction, {
//     bool isLoading = true,
//     bool isCustomError = false,
//     bool isStateOnly = false,
//   }) async {
//     // 現在のstateを保持
//     final prevState = state.copyWithPrevious(state);
//     // isLoadingがtrueの場合、stateをAsyncLoadingに更新
//     if (isLoading) state = AsyncLoading<T>();

//     // AsyncValue.guardを使って同期処理を実行
//     final asyncValue = await AsyncValue.guard<T>(() async {
//       if (isCustomError) {
//         return await futureFunction().catchError((e) => customErrorMessage(error: e));
//       }
//       return await futureFunction();
//     });

//     // ローディングを戻す
//     state = isStateOnly ? prevState : asyncValue;

//     // エラーがある場合、300ミリ秒後に非同期で戻す
//     if (asyncValue.hasError) {
//       // isStateOnly:trueの場合、エラー状態にする
//       if (isStateOnly) state = AsyncError(asyncValue.error!, StackTrace.current);

//       // いきなり「state = prevState」をするとwatchEXのダイアログが出ないため,タイミングをずらす
//       Future.delayed(const Duration(milliseconds: 300), () => state = prevState);
//     }

//     return asyncValue.requireValue;
//   }
// }

extension AsyncNotifierBaseEX<T> on AsyncNotifierBase<T> {
  /// - state更新の際にエラーだった場合、stateがAysncErrorのままになるため戻す
  /// - isLoading: 非同期処理の実行中は AsyncLoading 状態にするかどうか
  /// - isCustomError: 非同期処理でカスタムエラーを返すかどうか
  Future<T> futureGuard(
    Future<T> Function() futureFunction, {
    bool isLoading = true,
    bool isCustomError = false,
  }) async {
    // 現在のstateを保持
    final prevState = state.copyWithPrevious(state);
    // isLoadingがtrueの場合、stateをAsyncLoadingに更新
    if (isLoading) state = AsyncLoading<T>();

    // AsyncValue.guardを使って非同期処理を実行
    state = await AsyncValue.guard<T>(() async {
      // isCustomErrorがtrueの場合、エラー時にカスタムエラーメッセージを返す
      if (isCustomError) {
        return await futureFunction().catchError((e) => customErrorMessage(error: e));
      }
      return await futureFunction();
    });

    // エラーがある場合、300ミリ秒後にprevStateに戻す
    if (state.hasError) {
      // いきなり「state = prevState」をするとwatchEXのダイアログが出ないため,タイミングをずらす
      Future.delayed(const Duration(milliseconds: 300), () => state = prevState);
    }

    return state.requireValue;
  }
}
