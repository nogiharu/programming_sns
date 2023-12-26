import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

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
  Future<List<Message>> getMessages({String? id}) async {
    final messages =
        await _messageAPI.getMessagesDocumentList(chatRoomId: arg, id: id).then((docs) {
      return docs.documents
          .map(
            (doc) => MessageEX.fromMap(doc.data),
          )
          .toList()
          .reversed
          .toList();
    });

    return messages;
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
    // futureGuard(() async {
    //   if (state.value != null) {
    //     if (state.value!.scrollController.hasClients) {
    //       state.value.scrollController
    //       throw 'AAA';
    //       final messageList25Ago = await getMessages(id: '');
    //       return state.value!..loadMoreData(messageList25Ago);
    //     }
    //   }
    //   // print(state.value!.scrollController.hasClients);
    //   return state.value!;
    // });

    await update((data) async {
      final initialMessageList = data.initialMessageList;
      final messageList25Ago = await getMessages(id: initialMessageList.first.id);
      // final messageList25Ago = await getMessages(id: '');

      data.loadMoreData(messageList25Ago);

      return data;
    });
  }
}

// final firstMessageProvider = FutureProvider.family<Message, String>((ref, chatRoomId) async {
//   return ref.read(chatControllerProvider(chatRoomId).notifier).getFirstMessage();
// });
