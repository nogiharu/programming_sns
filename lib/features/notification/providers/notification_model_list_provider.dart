import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:chatview/markdown/at_mention_paragraph_node.dart';

final notificationModelListProvider =
    AutoDisposeAsyncNotifierProvider<NotificationModelListNotifier, List<NotificationModel>>(
        NotificationModelListNotifier.new);

class NotificationModelListNotifier extends AutoDisposeAsyncNotifier<List<NotificationModel>> {
  NotificationAPI get _notificationAPI => ref.watch(notificationAPIProvider);

  @override
  FutureOr<List<NotificationModel>> build() async {
    return await getNotificationList();
  }

  /// 作成イベント
  Future<void> createChatMentionEvent(Message message) async {
    message.message;

    // update((data) => data..insert(0, NotificationModel.fromMap(event.payload)));
  }

  /// 作成イベント
  Future<void> createChatReactionEvent(Message message) async {
    // update((data) => data..insert(0, NotificationModel.fromMap(event.payload)));
  }

  Future<void> createNotification({required NotificationModel notificationModel}) async {
    await futureGuard(
      () async {
        return await _notificationAPI
            .createNotificationDocument(notificationModel)
            .then((doc) => state.value!);
      },
    );
  }

  Future<List<NotificationModel>> getNotificationList() async {
    await futureGuard(
      () async {
        return await _notificationAPI.getNotificationDocumentList().then(
            (docs) => docs.documents.map((doc) => NotificationModel.fromMap(doc.data)).toList());
      },
    );

    return state.value!;
  }

  // NotificationModel getNotification(String notificationId) {
  //   return state.value!.firstWhere((e) => e.id == notificationId);
  // }
}
