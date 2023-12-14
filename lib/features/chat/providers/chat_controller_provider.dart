import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final chatControllerProvider = AutoDisposeAsyncNotifierProviderFamily<ChatControllerNotifier,
    (ChatController, List<Message>), String>(ChatControllerNotifier.new);

class ChatControllerNotifier
    extends AutoDisposeFamilyAsyncNotifier<(ChatController, List<Message>), String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  @override
  FutureOr<(ChatController, List<Message>)> build(arg) async {
    final initialMessageList = await getMessages();
    //  await ref.read(chatMessageListProvider(arg).notifier).build(arg);
    final chatUsers = await getChatUsers();

    final scrollController = ScrollController();

    scrollController.addListener(() {
      final position = scrollController.position;
      if (position.pixels == position.minScrollExtent) {
        print('OK');
        final chatController = state.value!;
        final lastMessageId = chatController.$1.initialMessageList.last.id;

        final minNextList = chatController.$2
            .skipWhile((e) => e.id != lastMessageId)
            .take(chatController.$1.initialMessageList.length)
            .toList();

        chatController.$1
          ..initialMessageList.clear()
          ..loadMoreData(minNextList);

        chatController.$1.scrollController.jumpTo(position.maxScrollExtent / 2);
      }
    });

    return (
      ChatController(
        initialMessageList: [...initialMessageList],
        scrollController: scrollController,
        chatUsers: chatUsers,
      ),
      initialMessageList
    );
    // return ChatController(
    //   initialMessageList: initialMessageList,
    //   scrollController: ScrollController(),
    //   chatUsers: chatUsers,
    // );
  }

  // void chatMessageEvent() {
  //   final stream = ref.watch(realtimeEventProvider);

  //   stream.listen((event) {
  //     final isUserCreateEvent =
  //         event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create') &&
  //             event.payload.containsValue(arg);

  //     final isUserUpdateEvent =
  //         event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update')
  //         //  &&  event.payload.containsValue(arg)
  //         ;

  //     final isMessageCreateEvent =
  //         event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
  //             event.payload.containsValue(arg);

  //     /// ユーザー作成イベント
  //     if (isUserCreateEvent) {
  //       debugPrint('USER_CREATE!');
  //       final user = UserModel.fromMap(event.payload);
  //       final chatUser = UserModel.toChatUser(user);
  //       update((data) => data..chatUsers.add(chatUser));
  //     }

  //     /// メッセージ更新イベント
  //     if (isUserUpdateEvent) {
  //       debugPrint('USER_UPDATE!');
  //       final user = UserModel.fromMap(event.payload);
  //       final chatUser = UserModel.toChatUser(user);
  //       update((data) {
  //         final index = data.chatUsers.indexWhere((e) => e.id == chatUser.id);
  //         return data..chatUsers[index] = chatUser;
  //       });
  //     }

  //     /// メッセージ作成イベント
  //     if (isMessageCreateEvent) {
  //       debugPrint('MESSAGE_CREATE!');
  //       final message = MessageEX.fromMap(event.payload);

  //       update((data) {
  //         final isClosed = data.messageStreamController.isClosed;
  //         if (!isClosed) data.addMessage(message);
  //         // if (!isClosed) data.addMessage(message);

  //         print(isClosed);
  //         print(message.message);
  //         return data;
  //       });
  //     }
  //   });
  // }

  void chatUserUpdate(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) {
      final index = data.$1.chatUsers.indexWhere((e) => e.id == chatUser.id);
      return data..$1.chatUsers[index] = chatUser;
    });
  }

  void chatUserCreate(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) => data..$1.chatUsers.add(chatUser));
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
        .catchError((e) => exceptionMessage(e));

    return messages;
  }

  /// メッセージリストに過去２５件メッセージ追加
  Future<void> addMessages() async {
    await update((data) async {
      final initialMessageList = data.$1.initialMessageList;
      final messageList25Ago = await getMessages(id: initialMessageList.first.id);
      if (messageList25Ago.isNotEmpty) {
        initialMessageList.clear();
      }
      // initialMessageList
      //     .removeAt(initialMessageList.indexWhere((e) => e.id != initialMessageList.last.id));

      data.$1.loadMoreData(messageList25Ago);
      final pixels = data.$1.scrollController.position.pixels;
      data.$1.scrollController.jumpTo(pixels / 2);

      data.$2.insertAll(0, messageList25Ago);

      return data;
    });
  }

  /// 予期せぬエラーだあ(T ^ T) 再立ち上げしてね(>_<)
  exceptionMessage(Object? e) {
    String message = '''
    予期せぬエラーだあ(T ^ T)
    再立ち上げしてね(>_<)
    ''';
    if (e is AppwriteException) {
      message = '${e.code}\n$message';
    }
    throw message;
  }
}
