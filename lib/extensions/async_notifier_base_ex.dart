// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unused_element, invalid_use_of_internal_member, implementation_imports

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:riverpod/src/async_notifier.dart';

extension AsyncNotifierBaseEX<T> on AsyncNotifierBase<T> {
  /// - state更新の際にエラーだった場合、stateがAysncErrorのままになるため戻す
  /// - isLoading: 非同期処理の実行中は AsyncLoading 状態にするかどうか
  /// - isCustomError: 非同期処理でカスタムエラーを返すかどうか
  Future<T> futureGuard(
    Future<T> Function() futureFunction, {
    bool isLoading = true,
    bool isCustomError = true,
  }) async {
    // 現在のstateを保持
    final prevState = state.copyWithPrevious(state);
    // isLoadingがtrueの場合、stateをAsyncLoadingに更新
    if (isLoading) state = AsyncLoading<T>();

    // 同期処理を実行
    state = await AsyncValue.guard<T>(() async {
      // isCustomErrorがtrueの場合、エラー時にカスタムエラーメッセージを返す
      return await futureFunction().catchErrorEX(isCustomError: isCustomError);
    });

    // エラーがある場合、非同期で300ミリ秒後にprevStateに戻す
    if (state.hasError) {
      // いきなり「state = prevState」をするとwatchEXのダイアログが出ないため,タイミングをずらす
      Future.delayed(const Duration(milliseconds: 300), () => state = prevState);
      return prevState.requireValue;
    }

    return state.requireValue;
  }

  /// state更新の際にエラーだった場合、stateがAysncErrorのままになるため戻す<br>
  /// `futureFunction`の戻りの型(R)が`state`の値と同一なら`state`の値を更新して`state`の値の値を返す<br>
  /// 同一でないなら`state`の値は更新せず、そのまま値(R)を返す<br>
  /// Rがnullなら必ずvoidにすること。`asyncGuard<void>(() async{}`
  /// - `isLoading` ローディング状態にするかどうか
  /// - `isCustomError` エラー時カスタムエラーを返すかどうか
  /// - `isValueUpdate` `state`の値を更新するかどうか
  Future<R> asyncGuard<R>(
    Future<R> Function() futureFunction, {
    bool isLoading = true,
    bool isCustomError = true,
    bool isValueUpdate = true,
  }) async {
    // 現在のstateを保持
    final prevState = state.copyWithPrevious(state);

    if (isLoading) state = AsyncLoading<T>();

    dynamic reslut;
    state = await AsyncValue.guard<T>(() async {
      // isCustomErrorがtrueの場合、エラー時にカスタムエラーメッセージを返す
      reslut = await futureFunction().catchErrorEX(isCustomError: isCustomError);
      // futureFunctionの戻り型がstateの値の型と同一か
      if (isValueUpdate && R == T) return reslut as T;
      return prevState.requireValue;
    });

    // エラーがある場合、300ミリ秒後にprevStateに戻す
    if (state.hasError) {
      // いきなり「state = prevState」をするとwatchEXのダイアログが出ないため,300ミリ秒後にエラーを戻す
      Future.delayed(const Duration(milliseconds: 300), () => state = prevState);
    }

    // reslutがnullの場合(Rがvoid、スローされた時)もあるため、prevStateを入れておく
    // 戻りの型をR?にすればいいだけの話だが、使う側が毎回nullチェックするのは面倒なので、以下を実施しておく
    return reslut ??= prevState.requireValue;
  }
}
