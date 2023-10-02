import 'dart:async';

import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/models/user_model.dart';

final chatControllerProvider =
    AsyncNotifierProvider<ChatControllerNotifier, (List<Message>, List<ChatUser>)>(
        ChatControllerNotifier.new);

class ChatControllerNotifier extends AsyncNotifier<(List<Message>, List<ChatUser>)> {
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
          print('ADDです：${message.createdAt}');
          return data;
        });
      }
    });
  }

  Future<List<ChatUser>> getChatUsers() async {
    return (await ref.read(userModelProvider.notifier).getUserModelList())
        .map((userModel) => UserModel.toChatUser(userModel))
        .toList();
  }

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

  Future<void> addMessages() async {
    print('メッセージ追加！');
    await update((data) async {
      final messages = data.$1;
      final messages25Ago = await getMessages(id: messages.first.id);

      data.$1.insertAll(0, messages25Ago);
      return data;
    });
  }
}
