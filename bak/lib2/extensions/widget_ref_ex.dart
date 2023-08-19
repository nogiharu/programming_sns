import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib2/common/error_dialog.dart';
import '../../lib2/common/loading.dart';
import '../../lib2/routes/router.dart';

/// スナックバー表示用のGlobalKey
final scaffoldMessengerKeyProvider = Provider(
  (_) => GlobalKey<ScaffoldMessengerState>(),
);

extension WidgetRefEx on WidgetRef {
  Widget watchEX<T>(
    ProviderListenable<AsyncValue<T>> asyncValueProvider, {
    required Widget Function(T) complete,
  }) {
    return watch(asyncValueProvider).when(
      data: (data) {
        return complete.call(data);
      },
      error: (e, _) {
        /// 画面の描画が始まったタイミングで状態の変更をする。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog<void>(
            context: read(rootNavigatorKeyProvider).currentContext!,
            builder: (context) => ErrorDialog(error: e.toString()),
          );
        });
        return Container();
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }

  void handleAsyncValue<T>(ProviderListenable<AsyncValue<T>> asyncValueProvider,
      {void Function(BuildContext context)? complete,
      String? completeMessage,
      bool isListen = false}) {
    if (isListen) {
      // ProviderをlistenしてAsyncValueの変更を監視する
      listen<AsyncValue<T>>(
        asyncValueProvider,
        (_, next) {
          // nextにはAsyncValueが格納されているので、AsyncValueの種類によって処理を分岐する
          next.whenOrNull(
            data: (_) {
              // 完了メッセージがあればスナックバーを表示する
              if (completeMessage != null) {
                final messengerState = read(scaffoldMessengerKeyProvider).currentState;
                messengerState?.showSnackBar(
                  SnackBar(
                    content: Text(completeMessage),
                  ),
                );
              }
              // completeが指定されている場合、コールバックを実行する
              complete?.call(read(rootNavigatorKeyProvider).currentContext!);
            },
            error: (e, _) {
              // エラーが発生したらエラーダイアログを表示する
              showDialog<void>(
                context: read(rootNavigatorKeyProvider).currentContext!,
                builder: (context) => ErrorDialog(error: e),
              );
            },
          );
          read(loadingProvider.notifier).state = next.isLoading;
        },
      );
    }
  }
}
