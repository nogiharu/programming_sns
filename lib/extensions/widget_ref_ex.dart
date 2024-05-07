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
        final res = complete(data);
        if (res is Widget) return res;
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

  // void handleAsyncValue<T>(ProviderListenable<AsyncValue<T>> asyncValueProvider,
  //     {void Function(BuildContext context)? complete,
  //     String? completeMessage,
  //     bool isListen = false}) {
  //   if (isListen) {
  //     // ProviderをlistenしてAsyncValueの変更を監視する
  //     listen<AsyncValue<T>>(
  //       asyncValueProvider,
  //       (_, next) {
  //         // nextにはAsyncValueが格納されているので、AsyncValueの種類によって処理を分岐する
  //         next.whenOrNull(
  //           data: (_) {
  //             // 完了メッセージがあればスナックバーを表示する
  //             if (completeMessage != null) {
  //               final messengerState = read(scaffoldMessengerKeyProvider).currentState;
  //               messengerState?.showSnackBar(
  //                 SnackBar(
  //                   content: Text(completeMessage),
  //                 ),
  //               );
  //             }
  //             // completeが指定されている場合、コールバックを実行する
  //             complete?.call(read(rootNavigatorKeyProvider).currentContext!);
  //           },
  //           error: (e, _) {
  //             // エラーが発生したらエラーダイアログを表示する
  //             showDialog<void>(
  //               context: read(rootNavigatorKeyProvider).currentContext!,
  //               builder: (context) => ErrorDialog(error: e),
  //             );
  //           },
  //         );
  //         read(loadingProvider.notifier).state = next.isLoading;
  //       },
  //     );
  //   }
  // }
}
