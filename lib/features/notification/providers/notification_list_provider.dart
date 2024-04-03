import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/realtime_event_provider.dart';
import 'package:programming_sns/enums/notification_type.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final aaa = StateProvider((ref) => 0);

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
  /// リレーションone wayしてもいいがID.uniqueはメッセージ作成後に採番されるため、採番後にやる必要がある
  void chatMentionEvent(RealtimeMessage event) {
    update((data) {
      if (event.payload['userDocumentId'] == _currentUser.documentId) {
        data = data..insert(0, NotificationModel.fromMap(event.payload));
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

  Future<List<NotificationModel>> getNotificationList() async {
    final queries = [
      Query.equal('userDocumentId', _currentUser.documentId),
      Query.equal('isRead', false),
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

  // NotificationModel getNotification(String notificationId) {
  //   return state.value!.firstWhere((e) => e.id == notificationId);
  // }
}
