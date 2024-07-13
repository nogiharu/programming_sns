import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/routes/router.dart';

/// スナックバー表示用のGlobalKey
final scaffoldMessengerKeyProvider = Provider(
  (_) => GlobalKey<ScaffoldMessengerState>(),
);

extension WidgetRefEX on WidgetRef {
  /// - asyncValueProvider AsyncValueを返すプロバイダー
  /// - complete 取得完了後のコールバック(data)
  /// - isBackgroundColorNone エラーダイアログ表示時の背景色を透明にするか
  /// - loading ローディング中に出したいやつ
  Widget watchEX<T>(
    ProviderListenable<AsyncValue<T>> asyncValueProvider, {
    required Function(T) complete,
    bool isBackgroundColorNone = false,
    Widget? loading,
  }) {
    return watch(asyncValueProvider).when(
      data: (data) {
        final result = complete(data);
        if (result is Widget) return result;
        // TODO ここがダサい
        return const SizedBox.shrink();
      },
      error: (e, s) {
        debugPrint('エラー:$e');
        debugPrint('スタックトレース:$s');
        // 画面の描画が終わったタイミングで状態の変更をする。（描画前に出すとエラーが出る）
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => showDialog<void>(
            barrierColor: isBackgroundColorNone ? Colors.transparent : null,
            context: read(rootNavigatorKeyProvider).currentContext!,
            builder: (_) => ErrorDialog(error: e),
          ),
        );
        // TODO ここがダサい
        return const SizedBox.shrink();
      },
      loading: () {
        debugPrint('ローディング');
        if (loading != null) return loading;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
