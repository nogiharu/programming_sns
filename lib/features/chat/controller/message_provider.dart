import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/features/chat/controller/chat_controller.dart';
import 'package:programming_sns/features/chat/controller/test.dart';
import 'package:programming_sns/models/user_model.dart';

final realtimeMessageProvider = StreamProvider.autoDispose((ref) async* {
  final stream = ref.watch(appwriteRealtimeProvider).subscribe([
    AppwriteConstants.messagesDocmentsChannels,
  ]).stream;

  // final chatControllerNotifier = ref.read(chatControllerProvider.notifier);
  // final isNotClosed = !chatControllerNotifier.chatController.messageStreamController.isClosed;
  await for (RealtimeMessage realtime in stream) {
    if (realtime.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create')) {
      yield MessageEX.fromMap(realtime.payload);
    }
  }
});

final chatMessagesAndChatUsersProvider2 = FutureProvider((ref) async {
  print('呼ばれたMessgae');
  final messageList = await ref.watch(messageAPIProvider).getMessagesDocumentList().then(
        (docList) => docList.documents
            .map(
              (doc) => MessageEX.fromMap(doc.data),
            )
            .toList(),
      );

  final chatUserList = (await ref.watch(userAPIProvider).getUsersDocumentList())
      .documents
      .map((e) => UserModel.toChatUser(UserModel.fromMap(e.data)))
      .toList();

  chatUserList.forEach((element) {
    print('USERだよ');
    print(element.id);
  });
  messageList.forEach((element) {
    print('messageだよ');
    print(element.sendBy);
  });
  return (messageList, chatUserList);
});

final chatMessagesAndChatUsersProvider =
    AsyncNotifierProvider<MessageNotifier, (List<Message>, List<ChatUser>)>(MessageNotifier.new);

class MessageNotifier extends AsyncNotifier<(List<Message>, List<ChatUser>)> {
  @override
  FutureOr<(List<Message>, List<ChatUser>)> build() async {
    print('呼ばれたMessgae');
    final messageList = await ref.watch(messageAPIProvider).getMessagesDocumentList().then(
          (docList) => docList.documents
              .map(
                (doc) => MessageEX.fromMap(doc.data),
              )
              .toList(),
        );

    final chatUserList = (await ref.watch(userAPIProvider).getUsersDocumentList())
        .documents
        .map((e) => UserModel.toChatUser(UserModel.fromMap(e.data)))
        .toList();

    final stream = ref.watch(appwriteRealtimeProvider).subscribe([
      AppwriteConstants.messagesDocmentsChannels,
      AppwriteConstants.usersDocumentsChannels,
    ]).stream;

    stream.listen((event) {
      print(event);
      if (event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create')) {
        print('USER_CREATE');
        print(event.payload);
        final user = UserModel.fromMap(event.payload);
        addUser(UserModel.toChatUser(user));
      }
      if (event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create')) {
        print('MESSAGE_CREATE');
        print(event.payload);
        final message = MessageEX.fromMap(event.payload);
        addMessage(message);
      }
      if (event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update')) {
        print('USER_UPDATE');
        print(event.payload);
        // final user = UserModel.fromMap(event.payload);
        // addUser(UserModel.toChatUser(user));
      }
    });

    return (messageList, chatUserList);
  }

  void addMessage(Message message) {
    update((data) {
      data.$1.add(message);
      return data;
    });
  }

  void addUser(ChatUser chatUser) {
    update((data) {
      data.$2.add(chatUser);
      return data;
    });
  }

  // void messagePayload() {
  //   const messagesDocments =
  //       'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollection}.documents';

  //   final stream = ref.watch(appwriteRealtimeProvider).subscribe([
  //     messagesDocments,
  //   ]).stream;

  //   stream.listen((event) {
  //     if (event.events.contains('$messagesDocments.*.create')) {
  //       final message = MessageEX.fromMap(event.payload);
  //       update((data) {
  //         data.add(message);
  //         return data;
  //       });
  //     }
  //   });
  // }
}
