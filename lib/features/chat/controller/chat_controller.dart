import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/features/chat/controller/message_provider.dart';
import 'package:programming_sns/features/chat/controller/test.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/models/user_model.dart';

// class ChatControllerNotifier extends AsyncNotifier<ChatController> {
//   @override
//   FutureOr<ChatController> build() async {
//     final messageList = (await ref.watch(messageAPIProvider).getMessagesDocumentList())
//         .documents
//         .map((e) => MessageEx.fromMap(e.data))
//         .toList();

//     final userModelList = await ref.watch(userModelProvider.notifier).getUserModelList();

//     return ChatController(
//       chatUsers: userModelList,
//       scrollController: ScrollController(),
//       initialMessageList: messageList,
//     );
//   }

//   Future<void> _onSendTap(
//     String message,
//     ReplyMessage replyMessage,
//     MessageType messageType,
//     UserModel userModel,
//   ) async {
//     // ref.watch(userModelProvider).value;
//     // final id = int.parse(Data.messageList.last.id) + 1;

//     final msg = Message(
//       id: ID.unique(),
//       createdAt: DateTime.now(),
//       message: message,
//       sendBy: userModel.id,
//       replyMessage: replyMessage,
//       messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
//     );

//     // Future.delayed(const Duration(milliseconds: 300), () {
//     //   _chatController.initialMessageList.last.setStatus = MessageStatus.undelivered;
//     // });
//     // Future.delayed(const Duration(seconds: 1), () {
//     //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
//     // });
//   }
// }

final chatControllerProvider =
    AsyncNotifierProvider<ChatControllerNotifier, ChatController>(ChatControllerNotifier.new);

class ChatControllerNotifier extends AsyncNotifier<ChatController> {
  @override
  FutureOr<ChatController> build() async {
    final messageList = await ref.read(messageAPIProvider).getMessagesDocumentList().then(
          (docList) => docList.documents
              .map(
                (doc) => MessageEX.fromMap(doc.data),
              )
              .toList(),
        );

    final chatUserList = (await ref.read(userModelProvider.notifier).getUserModelList())
        .map((e) => UserModel.toChatUser(e))
        .toList();

    return ChatController(
      chatUsers: chatUserList,
      scrollController: ScrollController(),
      initialMessageList: messageList,
    );
  }

  /// 自分を取る
  ChatController get chatController => state.maybeWhen(
        data: (data) => data,
        orElse: () => ChatController(
          chatUsers: [],
          initialMessageList: [],
          scrollController: ScrollController(),
        ),
      );

  Future<void> realtimeChatUserUpdate(UserModel userModel) async {
    update((data) {
      final index = data.chatUsers.indexWhere((e) => e.id == userModel.id);
      if (index < 1) return data;
      data.chatUsers[index] = UserModel.toChatUser(userModel);
      return data;
    });
  }

  void realtimeMessageUpdate(Message message) {
    // final curentUser = ref.watch(userModelProvider).value ?? UserModel.instance();

    print('呼ばれた1');
    update((data) {
      final exsist = data.initialMessageList.any((e) => e.id == message.id);

      if (exsist) return data;

      print('呼ばれた2');
      data.addMessage(message);
      return data;
    });
    // final curentUser = ref.watch(userModelProvider).value ?? UserModel.instance();
    // update((data) {
    //   final isNotClosed = !data.messageStreamController.isClosed;
    //   print('呼ばれた1');
    //   print(isNotClosed);
    //   final exsist = data.initialMessageList.any((e) => e.id == message.id);

    //   if (isNotClosed && exsist && curentUser != user) {
    //     return data;
    //   } else {
    //     print('呼ばれた2');
    //     data.addMessage(message);
    //     return data;
    //   }
    // });
  }

  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  /// ScrollControllerが破棄されないため
  void initScrollController() {
    update((data) {
      data.scrollController = ScrollController();
      return data;
    });
  }

  Future<void> delete() async {
    final messageList = await ref
        .watch(messageAPIProvider)
        .getMessagesDocumentList()
        .then((docList) => docList.documents.map((doc) => MessageEX.fromMap(doc.data)).toList());

    await Future.forEach(messageList, (e) async {
      await _messageAPI.deleteMessageDocument(e.id);
    });
  }

  /// メッセージ送信
  Future<void> onSendMessage(
      String message, ReplyMessage replyMessage, MessageType messageType) async {
    final currentUser = ref.read(userModelProvider.notifier).currentUser;

    final sendMessage = Message(
      id: ID.unique(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: currentUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
    );

    _futureGuard(
      () async {
        final doc = await _messageAPI
            .createMessageDocument(sendMessage)
            .catchError((e) => throw '${e.code}: MESSAGE_CREATE: MESSAGE作成できない( ;  ; ）');
        return update((data) {
          data.addMessage(MessageEX.fromMap(doc.data));
          return data;
        });
      },
    );
  }

  Future<void> _futureGuard(Future<ChatController> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = await AsyncValue.guard(futureFunction);
    if (state.hasError) {
      Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    }
  }
}
