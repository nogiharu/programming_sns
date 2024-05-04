// ignore_for_file: prefer_function_declarations_over_variables, invalid_return_type_for_catch_error

import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/routes/router.dart';

/// メンションしたメッセージの送信日付を特定するために使用
final mentionCreatedAtProvider = StateProvider<DateTime?>((ref) => null);

final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<NotificationListNotifier, List<NotificationModel>>(
        NotificationListNotifier.new);

class NotificationListNotifier extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  NotificationAPI get _notificationAPI => ref.watch(notificationAPIProvider);
  UserModel get _currentUser => ref.watch(userModelProvider).requireValue;
  String? firstDocumentId;

  @override
  FutureOr<List<NotificationModel>> build() async {
    /// 通知作成イベント
    ref.watch(notificationEventProvider);

    /// 最初のデータ取得
    await _notificationAPI.getList(queries: [
      Query.equal('userDocumentId', _currentUser.documentId),
      Query.limit(1),
    ]).then((e) => firstDocumentId = e.firstOrNull?.documentId);

    return await _notificationAPI.getList(queries: [
      Query.equal('userDocumentId', _currentUser.documentId),
      Query.orderDesc('createdAt'),
    ]);
  }

  /// メンションイベント
  void createStateEvent(RealtimeMessage event) {
    update((data) {
      if (event.payload['userDocumentId'] == _currentUser.documentId) {
        final notification = NotificationModel.fromMap(event.payload);
        data = data..insert(0, notification);

        // どのメッセージがメンションされたか特定するために使用
        // ※ messageIdは作成後にIDが採番されるため
        ref.read(snackBarProvider)(
          message: '${notification.sendByUserName}さんからメンションされました(*^^*)',
          onTap: () {
            final context = ref.read(shellNavigatorKeyProvider).currentContext;
            final chatScreenPath = '${NotificationScreen.metadata['path']}/${ChatScreen.path}';
            // CHAT画面に遷移
            context!.go(chatScreenPath, extra: {
              'label': notification.chatRoomLabel,
              'chatRoomId': notification.chatRoomId,
            });

            ref.read(mentionCreatedAtProvider.notifier).state = notification.createdAt;
          },
        );
      }

      return data;
    });
  }

  Future<void> updateState({required NotificationModel notificationModel}) async {
    await futureGuard(() async {
      return await _notificationAPI.update(notificationModel).then((notification) {
        final index = state.value!.indexWhere((e) => e.documentId == notification.documentId);
        return state.value!..[index] = notification;
      });
    }, isLoading: false);
  }

  Future<void> addStateList() async {
    final data = state.requireValue;

    if (data.isEmpty || firstDocumentId == data.last.documentId) return;

    await futureGuard(
      () async {
        return await _notificationAPI.getList(
          queries: [
            Query.equal('userDocumentId', _currentUser.documentId),
            Query.orderDesc('createdAt'),
            Query.cursorAfter(data.last.documentId!),
          ],
        ).then((data) => state.requireValue..addAll(data));
      },
      isLoading: false,
    );
  }

  // Future<List<NotificationModel>> getList({String documentId = ''}) async {
  //   final queries = [
  //     Query.equal('userDocumentId', _currentUser.documentId),
  //     Query.orderDesc('createdAt'),
  //   ];

  //   if (documentId.isNotEmpty) {
  //     queries.add(Query.cursorAfter(documentId));
  //   }

  //   return await _notificationAPI
  //       .getList(queries: queries)
  //       .catchError((e) => state = AsyncError(e, StackTrace.current));
  // }
}
