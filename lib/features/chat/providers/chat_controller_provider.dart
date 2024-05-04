// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final firstChatMessageProvider = FutureProviderFamily<Message, String>((ref, chatRoomId) async {
  return ref.read(chatControllerProvider(chatRoomId).notifier).getFirstMessage();
});

final textEditingControllerProvider = Provider<Map<String, TextEditingController>>((ref) {
  return {};
});

final chatControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatControllerNotifier, ChatController, String>(
        ChatControllerNotifier.new);

class ChatControllerNotifier extends AutoDisposeFamilyAsyncNotifier<ChatController, String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);
  String? firstDocumentId;

  @override
  FutureOr<ChatController> build(arg) async {
    final initialMessageList = await getMessages();

    final chatUsers = await getChatUsers();

    firstDocumentId = (await getFirstMessage()).id;

    return ChatController(
      initialMessageList: initialMessageList,
      scrollController: ScrollController(),
      chatUsers: chatUsers,
    );
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

  /// ユーザーリスト取得し、チャットユーザーリストに変換
  Future<List<ChatUser>> getChatUsers() async {
    return await ref.watch(userAPIProvider).getList(queries: [
      Query.limit(100000),
      Query.equal('isDeleted', false),
      Query.contains('chatRoomIds', arg),
    ]).then((users) => users.map((user) => UserModel.toChatUser(user)).toList());
  }

  /// メッセージ一覧取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<List<Message>> getMessages({String? before25MessageId}) async {
    final queries = [
      Query.orderDesc('createdAt'),
      Query.equal('chatRoomId', arg),
      // Query.limit(25),
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
  Future<Message> getFirstMessage() async {
    final queries = [
      Query.equal('chatRoomId', arg),
      Query.orderAsc('createdAt'),
      Query.limit(1),
    ];
    final messages = await _messageAPI
        .getList(queries: queries)
        .then((e) => e.first)
        .catchError(ref.read(showDialogProvider));

    return messages;
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
}
