// ignore_for_file: prefer_function_declarations_over_variables, invalid_return_type_for_catch_error

import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/realtime_event_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/screens/old/chat_screen.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/models/user_model2.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:programming_sns/routes/router.dart';

final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<NotificationListNotifier, List<NotificationModel>>(
        NotificationListNotifier.new);

class NotificationListNotifier extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  NotificationAPI get _notificationAPI => ref.watch(notificationAPIProvider);
  UserModel get _currentUser => ref.watch(userProvider).requireValue;
  String? firstDocumentId;

  /// メンションを特定するために使用
  DateTime? mentionCreatedAt;

  @override
  FutureOr<List<NotificationModel>> build() async {
    /// 通知作成イベント
    realtimeEvent();

    /// 最初のデータ取得
    final firstList = await _notificationAPI.getList(
      queries: [
        Query.equal('userDocumentId', _currentUser.id),
        Query.orderAsc('createdAt'),
        Query.limit(1),
      ],
    );
    firstDocumentId = firstList.firstOrNull?.documentId;

    return await getAllList();
  }

  //========================== ステート(API) START ==========================
  Future<void> updateState(NotificationModel notification) async {
    await futureGuard(
      () async {
        final updatedNotification = await _notificationAPI.update(notification);
        final index =
            state.requireValue.indexWhere((e) => e.documentId == updatedNotification.documentId);

        return state.requireValue..[index] = updatedNotification;
      },
      isLoading: false,
    );
  }

  Future<void> addStateList() async {
    final data = state.requireValue;

    if (data.isEmpty || firstDocumentId == data.last.documentId) return;

    await futureGuard(
      () async {
        final nextList = await getAllList(nextPagenationId: data.last.documentId);

        return state.requireValue..addAll(nextList);
      },
      isLoading: false,
    );
  }
  //========================== ステート(API) END ==========================

  //========================== API START ==========================

  Future<List<NotificationModel>> getAllList({String? nextPagenationId}) async {
    final queries = [
      Query.equal('userDocumentId', _currentUser.id),
      Query.orderDesc('createdAt'),
    ];

    if (nextPagenationId != null) {
      queries.add(Query.cursorAfter(nextPagenationId));
    }

    return await _notificationAPI.getList(queries: queries);
  }
  //========================== API END ==========================

  //========================== イベント START ==========================

  void realtimeEvent() {
    ref.listen(realtimeEventProvider, (_, next) {
      next.whenOrNull(
        data: (event) {
          final isNotificationCreateEvent =
              event.events.contains('${AppwriteConstants.kNotificationDocmentsChannels}.*.create');

          /// 通知作成イベント
          if (isNotificationCreateEvent) {
            debugPrint('NOTIFICATION_CREATE!');
            _createStateEvent(event);
          }
        },
      );
    });
  }

  /// メンションイベント
  void _createStateEvent(RealtimeMessage event) {
    update((data) {
      if (event.payload['userDocumentId'] == _currentUser.id) {
        final notification = NotificationModel.fromMap(event.payload);
        data.insert(0, notification);

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

            mentionCreatedAt = notification.createdAt;
          },
        );
      }

      return data;
    });
  }
  //========================== イベント END ==========================
}
