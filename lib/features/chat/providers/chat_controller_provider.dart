import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/common/error_dialog.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/routes/router.dart';

final firstChatMessageProvider = FutureProviderFamily<Message, String>((ref, chatRoomId) async {
  return ref.read(chatControllerProvider(chatRoomId).notifier).getFirstMessage();
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

  void chatUserUpdate(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) {
      final index = data.chatUsers.indexWhere((e) => e.id == chatUser.id);
      return data..chatUsers[index] = chatUser;
    });
  }

  void chatUserCreate(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) => data..chatUsers.add(chatUser));
  }

  /// ユーザーリスト取得し、チャットユーザーリストに変換
  Future<List<ChatUser>> getChatUsers() async {
    return (await ref.read(userModelProvider.notifier).getUserModelList())
        .map((userModel) => UserModel.toChatUser(userModel))
        .toList();
  }

  /// メッセージ一覧取得
  /// FIXME state更新できない（futureGuard使えない）
  Future<List<Message>> getMessages({String? id}) async {
    final messages = await _messageAPI
        .getMessagesDocumentList(chatRoomId: arg, id: id)
        .then(
          (docs) => docs.documents
              .map(
                (doc) => MessageEX.fromMap(doc.data),
              )
              .toList()
              .reversed
              .toList(),
        )
        .catchError((e) async {
      state.value!.scrollController.jumpTo(state.value!.scrollController.position.minScrollExtent);
      return await showDialog(
        context: ref.read(rootNavigatorKeyProvider).currentContext!,
        builder: (_) => ErrorDialog(error: e),
      );
    });

    return messages;
  }

  /// メッセージ作成
  /// FIXME state更新できない（futureGuard使えない）
  Future<void> createMessage(Message message) async {
    await ref.read(messageAPIProvider).createMessageDocument(message).catchError((e) async {
      state.value!.scrollController.jumpTo(state.value!.scrollController.position.minScrollExtent);
      return await showDialog(
        context: ref.read(rootNavigatorKeyProvider).currentContext!,
        builder: (_) => ErrorDialog(error: e),
      );
    });
  }

  /// 最初のメッセージ取得
  Future<Message> getFirstMessage() async {
    final messages = await _messageAPI
        .getFirstMessageDocument(
          chatRoomId: arg,
        )
        .then((docs) => docs.documents.map((doc) => MessageEX.fromMap(doc.data)).first);

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