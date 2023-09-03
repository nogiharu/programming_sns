import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/extensions/message_ex.dart';
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
    final messageList = (await ref.watch(messageAPIProvider).getMessagesDocumentList())
        .documents
        .map((e) => MessageEX.fromMap(e.data))
        .toList();

    final chatUserList = (await ref.watch(userModelProvider.notifier).getUserModelList())
        .map((e) => UserModel.toChatUser(e))
        .toList();

    return ChatController(
      chatUsers: chatUserList,
      scrollController: ScrollController(),
      initialMessageList: messageList,
    );
  }

  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);
  UserModel get getCurrentUser => ref.watch(userModelProvider).maybeWhen(
        orElse: UserModel.instance,
        data: (data) => data,
      );

  /// ScrollControllerが破棄されないため
  void initScrollController() {
    update((chatController) {
      chatController.scrollController = ScrollController();
      return chatController;
    });
  }

  /// メッセージ送信
  Future<void> onSendMessage(
      String message, ReplyMessage replyMessage, MessageType messageType) async {
    final sendMessage = Message(
      id: ID.unique(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: getCurrentUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
    );

    _futureGuard(
      () async {
        final doc = await _messageAPI
            .createMessageDocument(sendMessage)
            .catchError((e) => throw '${e.code}: MESSAGE_CREATE: MESSAGE作成できない( ;  ; ）');
        return update((chatController) {
          chatController.addMessage(MessageEX.fromMap(doc.data));
          return chatController;
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
