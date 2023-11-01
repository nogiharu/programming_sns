import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final chatMessageProvider =
    AsyncNotifierProvider<ChatMessageNotifier, (List<Message>, List<ChatUser>)>(
        ChatMessageNotifier.new);

class ChatMessageNotifier extends AsyncNotifier<(List<Message>, List<ChatUser>)> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  @override
  FutureOr<(List<Message>, List<ChatUser>)> build() async {
    print('呼ばれたMessgae');
    final messages = await getMessages();

    final chatUsers = await getChatUsers();

    chatEvent();

    return (messages, chatUsers);
  }

  void chatEvent() {
    final stream = ref.watch(appwriteRealtimeProvider).subscribe([
      AppwriteConstants.messagesDocmentsChannels,
      AppwriteConstants.usersDocumentsChannels,
    ]).stream;

    stream.listen((event) {
      final isUserCreateEvent =
          event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create');

      final isUserUpdateEvent =
          event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update');

      final isMessageCreateEvent =
          event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create');

      /// ユーザー作成イベント
      if (isUserCreateEvent) {
        debugPrint('USER_CREATE!');
        final user = UserModel.fromMap(event.payload);
        final chatUser = UserModel.toChatUser(user);
        update((data) => data..$2.add(chatUser));
      }

      /// メッセージ更新イベント
      if (isUserUpdateEvent) {
        debugPrint('USER_UPDATE!');
        final user = UserModel.fromMap(event.payload);
        final chatUser = UserModel.toChatUser(user);
        update((data) {
          final index = data.$2.indexWhere((e) => e.id == chatUser.id);
          data.$2[index] = chatUser;
          return data;
        });
      }

      /// メッセージ作成イベント
      if (isMessageCreateEvent) {
        debugPrint('MESSAGE_CREATE!');
        final message = MessageEX.fromMap(event.payload);
        update((data) => data..$1.add(message));
      }
    });
  }

  /// ユーザーリスト取得し、チャットユーザーリストに変換
  Future<List<ChatUser>> getChatUsers() async {
    return (await ref.read(userModelProvider.notifier).getUserModelList())
        .map((userModel) => UserModel.toChatUser(userModel))
        .toList();
  }

  /// メッセージ一覧取得
  Future<List<Message>> getMessages({String? id}) async {
    final messages = await _messageAPI
        .getMessagesDocumentList(id: id)
        .then(
          (docs) => docs.documents
              .map(
                (doc) => MessageEX.fromMap(doc.data),
              )
              .toList()
              .reversed
              .toList(),
        )
        .catchError((e) => throw '${e.code}: MESSAGE_LSIT メッセージ取得できない( ;  ; ）');

    return messages;
  }

  /// メッセージリストに過去２５件メッセージ追加
  Future<void> addMessages() async {
    await update((data) async {
      final messages = data.$1;
      final messages25Ago = await getMessages(id: messages.first.id);

      data.$1.insertAll(0, messages25Ago);
      return data;
    });
  }
}
