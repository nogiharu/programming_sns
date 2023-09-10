import 'dart:async';

import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/extensions/message_ex.dart';

import 'package:programming_sns/models/user_model.dart';

final messagesWithChatUsersProvider =
    AsyncNotifierProvider<MessagesWithChatUsersNotifier, (List<Message>, List<ChatUser>)>(
        MessagesWithChatUsersNotifier.new);

class MessagesWithChatUsersNotifier extends AsyncNotifier<(List<Message>, List<ChatUser>)> {
  @override
  FutureOr<(List<Message>, List<ChatUser>)> build() async {
    chatEvent();

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

    return (messageList, chatUserList);
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

      if (isUserCreateEvent) {
        print('USER_CREATE');
        final user = UserModel.fromMap(event.payload);
        final chatUser = UserModel.toChatUser(user);
        update((data) {
          data.$2.add(chatUser);
          return data;
        });
      }
      if (isUserUpdateEvent) {
        print('USER_UPDATE');
        final user = UserModel.fromMap(event.payload);
        final chatUser = UserModel.toChatUser(user);
        update((data) {
          final index = data.$2.indexWhere((e) => e.id == chatUser.id);
          data.$2[index] = chatUser;
          return data;
        });
      }
      if (isMessageCreateEvent) {
        print('MESSAGE_CREATE');
        final message = MessageEX.fromMap(event.payload);
        update((data) {
          data.$1.add(message);
          return data;
        });
      }
    });
  }
}
