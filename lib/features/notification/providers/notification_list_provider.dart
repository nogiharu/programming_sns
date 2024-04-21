// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/realtime_event_provider.dart';
import 'package:programming_sns/enums/notification_type.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/routes/router.dart';

final mentionMessageIdProvider = StateProvider((ref) => '');

final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<NotificationListNotifier, List<NotificationModel>>(
        NotificationListNotifier.new);

class NotificationListNotifier extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  NotificationAPI get _notificationAPI => ref.watch(notificationAPIProvider);
  UserModel get _currentUser => ref.watch(userModelProvider).requireValue;

  @override
  FutureOr<List<NotificationModel>> build() async {
    /// 通知作成イベント
    ref.watch(notificationEventProvider);
    return await getNotificationList();
  }

  /// メンションイベント
  void chatMentionEvent(RealtimeMessage event) {
    update((data) {
      if (event.payload['userDocumentId'] == _currentUser.documentId) {
        final notification = NotificationModel.fromMap(event.payload);
        data = data..insert(0, notification);

        chatMentionTransition(notification: notification, isShowSnackBar: true);
      }

      return data;
    });
  }

  Future<void> createNotification({required NotificationModel notificationModel}) async {
    await futureGuard(
      () async {
        return await _notificationAPI.createNotificationDocument(notificationModel).then((doc) {
          return state.value!..insert(0, NotificationModel.fromMap(doc.data));
        });
      },
    );
  }

  Future<void> updateNotification({required NotificationModel notificationModel}) async {
    await futureGuard(() async {
      return await _notificationAPI.updateNotificationDocument(notificationModel).then((doc) {
        final notification = NotificationModel.fromMap(doc.data);
        final index = state.value!.indexWhere((e) => e.documentId == notification.documentId);
        return state.value!..[index] = notification;
      });
    }, isLoading: false);
  }

  Future<List<NotificationModel>> getNotificationList() async {
    final queries = [
      Query.equal('userDocumentId', _currentUser.documentId),
      Query.orderDesc('createdAt'),
      Query.limit(10000),
    ];
    return await futureGuard(
      () async {
        return await _notificationAPI.getNotificationDocumentList(queries: queries).then((docs) {
          return docs.documents.map((doc) => NotificationModel.fromMap(doc.data)).toList();
        });
      },
    );

    // return state.value!;
  }

  Future<void> chatMentionTransition(
      {required NotificationModel notification, bool isShowSnackBar = false}) async {
    // どのメッセージがメンションされたか特定するために使用
    // ※ messageIdは作成後にIDが採番されるため
    final queries = [
      Query.equal('message', notification.text),
      Query.equal('updatedAt', notification.createdAt.millisecondsSinceEpoch),
    ];
    await ref.read(messageAPIProvider).getMessageDocumentList(queries: queries).then((e) {
      if (e.documents.isEmpty) return;
      final messageDocumentId = e.documents.first.data['\$id'];
      ref.read(mentionMessageIdProvider.notifier).state = messageDocumentId;
    });

    ref.read(snackBarProvider)(
      message: '${notification.sendByUserName}さんからメンションされました(*^^*)',
      onTap: () => navigateToChatScreen(notification: notification),
    );
  }

  void navigateToChatScreen({required NotificationModel notification}) {
    // CHAT画面に遷移
    ref.read(shellNavigatorKeyProvider).currentContext!.goNamed(ChatScreen.path, extra: {
      'label': notification.chatRoomLabel,
      'chatRoomId': notification.chatRoomId,
    });
    // 既読していないなら既読する awaitはしない
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier).updateNotification(
            notificationModel: notification.copyWith(isRead: true),
          );
    }
  }
}
