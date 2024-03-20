import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/notification_api_provider.dart';
import 'package:programming_sns/enums/notification_type.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final notificationModelListProvider =
    AsyncNotifierProvider<NotificationModelListNotifier, List<NotificationModel>>(
        NotificationModelListNotifier.new);

class NotificationModelListNotifier extends AsyncNotifier<List<NotificationModel>> {
  NotificationAPI get _notificationAPI => ref.watch(notificationAPIProvider);
  UserModel get _currentUser => ref.watch(userModelProvider).requireValue;

  @override
  FutureOr<List<NotificationModel>> build() async {
    return await getNotificationList();
  }

  /// 作成イベント
  /// リレーションone wayしてもいいがID.uniqueはメッセージ作成後に採番されるため、採番後にやる必要がある
  Future<void> chatMentionEvent(Message message) async {
    final sendByUser = await ref.read(userModelProvider.notifier).getUserModel(message.sendBy);

    await Future.forEach(message.mentionUserIds!, (userId) async {
      final notificationModel = NotificationModel.instance(
        userId: userId,
        chatRoomId: message.chatRoomId,
        messageId: message.id,
        text: message.message,
        notificationType: NotificationType.mention,
        sendByUserName: sendByUser.name,
      );
      await createNotification(notificationModel: notificationModel);
    });

    // update((data) => data..insert(0, NotificationModel.fromMap(event.payload)));
  }

  /// 作成イベント
  Future<void> chatReactionEvent(Message message) async {
    // update((data) => data..insert(0, NotificationModel.fromMap(event.payload)));
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
      Query.equal('userId', _currentUser.documentId),
      Query.orderDesc('createdAt'),
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
