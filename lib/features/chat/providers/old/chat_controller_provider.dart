// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/realtime_event_provider.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

final textEditingControllerProvider = Provider<Map<String, TextEditingController>>((ref) {
  return {};
});

/// FIXME 適当に作ったから消します。
final chatControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatControllerNotifier, ChatController, String>(
        ChatControllerNotifier.new);

/// FIXME 適当に作ったから消します。
class ChatControllerNotifier extends AutoDisposeFamilyAsyncNotifier<ChatController, String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);
  String? firstMessageId;

  @override
  FutureOr<ChatController> build(arg) async {
    realtimeEvent();

    final initialMessageList = await getMessages();

    // final chatUsers = await getChatUsers();

    firstMessageId = await getFirstMessageId();

    return ChatController(
      initialMessageList: initialMessageList,
      scrollController: ScrollController(),
      chatUsers: [],
    );
  }

  /// ユーザーリスト取得し、チャットユーザーリストに変換
  // Future<List<ChatUser>> getChatUsers() async {
  //   return await ref
  //       .read(userProvider.notifier)
  //       .getAllList(chatRoomId: arg)
  //       .then((users) => users.map((user) => UserModel.toChatUser(user)).toList());
  // }

  /// メッセージ一覧取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<List<Message>> getMessages({String? before25MessageId}) async {
    final queries = [
      Query.orderDesc('createdAt'),
      Query.equal('chatRoomId', arg),
    ];
    // idより前を取得
    if (before25MessageId != null) queries.add(Query.cursorAfter(before25MessageId));

    final messages = await _messageAPI
        .getList(queries: queries)
        .then((e) => e.reversed.toList())
        .catchError(ref.read(showDialogProvider));

    return messages;
  }

  /// メッセージ作成
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> createMessage(Message message, {List<String>? mentionList}) async {
    await ref.read(messageAPIProvider).create(message).catchError(ref.read(showDialogProvider));
  }

  /// 最初のメッセージ取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<String?> getFirstMessageId() async {
    final queries = [
      Query.equal('chatRoomId', arg),
      Query.orderAsc('createdAt'),
      Query.limit(1),
    ];

    return await _messageAPI
        .getList(queries: queries)
        .then((e) => e.firstOrNull?.id)
        .catchError(ref.read(showDialogProvider));
  }

  /// メッセージ編集
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> updateMessage(Message message) async {
    await ref.read(messageAPIProvider).update(message).catchError(ref.read(showDialogProvider));
  }

  /// メッセージ編集
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> deleteMessage(Message message) async {
    await ref
        .read(messageAPIProvider)
        .update(message.copyWith(isDeleted: true))
        .catchError(ref.read(showDialogProvider));
  }

  void realtimeEvent() {
    ref.listen(realtimeEventProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          /// ユーザー更新イベント
          final isUserUpdateEvent =
              data.events.contains('${AppwriteConstants.kUsersDocumentsChannels}.*.update') &&
                  (data.payload['chatRoomIds'] as List<dynamic>).contains(arg);

          /// メッセージ作成イベント
          final isMessageCreateEvent =
              data.events.contains('${AppwriteConstants.kMessagesDocmentsChannels}.*.create') &&
                  data.payload.containsValue(arg);

          /// メッセージ更新イベント
          final isMessageUpdateEvent =
              data.events.contains('${AppwriteConstants.kMessagesDocmentsChannels}.*.update') &&
                  data.payload.containsValue(arg);

          /// ユーザー更新イベント
          if (isUserUpdateEvent) {
            debugPrint('CHAT_USER_UPDATE!');
            updateChatUserEvent(data);
          }

          /// メッセージ作成イベント
          if (isMessageCreateEvent) {
            debugPrint('MESSAGE_CREATE!');
            final message = MessageEX.fromMap(data.payload);
            state.value?.addMessage(message);
          }

          /// メッセージ更新イベント
          if (isMessageUpdateEvent) {
            debugPrint('MESSAGE_UPDATE!');
            updateMessageEvent(data);
          }
        },
      );
    });
  }

  void updateChatUserEvent(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) {
      final index = data.chatUsers.indexWhere((e) => e.id == chatUser.id);
      // ユーザがいない場合は追加
      if (index == -1) {
        data.chatUsers.add(chatUser);
      } else {
        // 更新
        data.chatUsers[index] = chatUser;
      }
      return data;
    });
  }

  void updateMessageEvent(RealtimeMessage event) {
    final message = MessageEX.fromMap(event.payload);
    update((data) {
      final index = data.initialMessageList.indexWhere((e) => e.id == message.id);
      return data..initialMessageList[index] = message;
    });
  }
}
