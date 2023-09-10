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

final getMessagesAndChatUsersProvider =
    FutureProvider<(List<Message>, List<ChatUser>)>((ref) async {
  final messageList = (await ref.watch(messageAPIProvider).getMessagesDocumentList())
      .documents
      .map((e) => MessageEX.fromMap(e.data))
      .toList();

  final chatUserList = (await ref.watch(userAPIProvider).getUsersDocumentList())
      .documents
      .map((e) => UserModel.toChatUser(UserModel.fromMap(e.data)))
      .toList();

  print('毎回かな？');
  return (messageList, chatUserList);
});

final chatControllerProvider2 =
    NotifierProvider<ChatControllerNotifier2, ChatController>(ChatControllerNotifier2.new);

class ChatControllerNotifier2 extends Notifier<ChatController> {
  @override
  ChatController build() {
    return ChatController(
      chatUsers: [],
      scrollController: ScrollController(),
      initialMessageList: [],
    );
  }

  /// ScrollControllerが破棄されないため
  void initScrollController() {
    state.scrollController = ScrollController();
  }

  ChatController initializeController(List<Message> initialMessageList, List<ChatUser> chatUsers) {
    state.chatUsers = chatUsers;
    state.initialMessageList = initialMessageList;

    return state;
  }

  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);
  UserAPI get _userAPI => ref.watch(userAPIProvider);

  UserModel get getCurrentUser => ref.watch(userModelProvider).maybeWhen(
        orElse: UserModel.instance,
        data: (data) => data,
      );

  Future<void> onSendTap(String message, ReplyMessage replyMessage, MessageType messageType) async {
    final msg = Message(
      id: ID.unique(),
      createdAt: DateTime.now(),
      message: message,
      sendBy: getCurrentUser.id,
      replyMessage: replyMessage,
      messageType: MessageType.text == messageType ? MessageType.custom : messageType, //TODO カスタム
    );
    print('送信');
    final doc = await _messageAPI.createMessageDocument(msg);
    // state.addMessage(MessageEX.fromMap(doc.data));
    // .whenComplete(() => state.addMessage(msg));
    // state.addMessage(msg);
    // addMessage(msg);
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
  // Future<void> addMessage(Message message) async {
  //   _futureGuard(
  //     () async {
  //       final doc = await _messageAPI
  //           .createMessageDocument(message)
  //           .catchError((e) => throw '${e.code}: MESSAGE_CREATE: MESSAGE作成できない( ;  ; ）');
  //       return update((chatController) {
  //         chatController.addMessage(MessageEx.fromMap(doc.data));
  //         return chatController;
  //       });
  //     },
  //   );
  // }

  // Future<void> _futureGuard(Future<ChatController> Function() futureFunction) async {
  //  final asyncState = AsyncData(state);
  //   final prevState = asyncState.copyWithPrevious(asyncState);
  //   state = await AsyncValue.guard(futureFunction).then((value) => value.value!);
  //   if (asyncState.hasError) {
  //     Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
  //   }
  // }

  // copyWith({
  //   List<ChatUser>? chatUsers,
  //   List<Message>? initialMessageList,
  //   ScrollController? scrollController,
  // }) {
  //   return ChatController(
  //     chatUsers: state.chatUsers,
  //     initialMessageList: state.initialMessageList,
  //     scrollController: state.scrollController,
  //   );
  // }
}
