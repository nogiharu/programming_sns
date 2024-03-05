// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/features/profile/providers/user_model_provider.dart';
import 'package:programming_sns/features/profile/models/user_model.dart';

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

  @override
  FutureOr<ChatController> build(arg) async {
    final initialMessageList = await getMessages();

    final chatUsers = await getChatUsers();

    return ChatController(
      initialMessageList: initialMessageList,
      scrollController: ScrollController(),
      chatUsers: chatUsers,
    );
  }

  void updateChatUser(RealtimeMessage event) {
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

  void updateMessage(RealtimeMessage event) {
    final message = MessageEX.fromMap(event.payload);
    update((data) {
      final index = data.initialMessageList.indexWhere((e) => e.id == message.id);
      return data..initialMessageList[index] = message;
    });
  }

  /// ユーザーリスト取得し、チャットユーザーリストに変換
  Future<List<ChatUser>> getChatUsers() async {
    return (await ref.read(userModelProvider.notifier).getUserModelList(chatRoomId: arg))
        .map((userModel) => UserModel.toChatUser(userModel))
        .toList();
  }

  /// メッセージ一覧取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<List<Message>> getMessages({String? id}) async {
    final messages = await _messageAPI
        .getMessagesDocumentList(chatRoomId: arg, id: id)
        .then((docs) => docs.documents
            .map(
              (doc) => MessageEX.fromMap(doc.data),
            )
            .toList()
            .reversed
            .toList())
        .catchError(ref.read(showDialogProvider));

    return messages;
  }

  /// メッセージ作成
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> createMessage(Message message) async {
    await ref
        .read(messageAPIProvider)
        .createMessageDocument(message)
        .catchError(ref.read(showDialogProvider));
  }

  /// 最初のメッセージ取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<Message> getFirstMessage() async {
    final messages = await _messageAPI
        .getFirstMessageDocument(
          chatRoomId: arg,
        )
        .then((docs) => docs.documents.map((doc) => MessageEX.fromMap(doc.data)).first)
        .catchError(ref.read(showDialogProvider));

    return messages;
  }

  /// メッセージリストに過去２５件メッセージ追加
  Future<void> addMessages() async {
    await update((data) async {
      final initialMessageList = data.initialMessageList;
      final messageList25Ago = await getMessages(id: initialMessageList.first.id);

      data.loadMoreData(messageList25Ago);

      return data;
    });
  }
}
