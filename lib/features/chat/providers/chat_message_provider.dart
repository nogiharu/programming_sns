// import 'dart:async';

// import 'package:appwrite/appwrite.dart';
// import 'package:chatview/chatview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:programming_sns/apis/message_api.dart';
// import 'package:programming_sns/constants/appwrite_constants.dart';
// import 'package:programming_sns/extensions/extensions.dart';
// import 'package:programming_sns/features/event/realtime_event_provider.dart';
// import 'package:programming_sns/features/user/providers/user_model_provider.dart';
// import 'package:programming_sns/features/user/models/user_model.dart';

// final chatMessageUserListProvider = AutoDisposeAsyncNotifierProviderFamily<
//     ChatMessageUserListNotifier,
//     (List<Message>, List<ChatUser>),
//     String>(ChatMessageUserListNotifier.new);

// class ChatMessageUserListNotifier
//     extends AutoDisposeFamilyAsyncNotifier<(List<Message>, List<ChatUser>), String> {
//   MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

//   @override
//   FutureOr<(List<Message>, List<ChatUser>)> build(arg) async {
//     print('検知');
//     final messages = await getMessages();

//     final chatUsers = await getChatUsers();

//     // chatMessageEvent();

//     return (messages, chatUsers);
//   }

//   // void chatMessageEvent() {
//   //   final stream = ref.watch(realtimeEventProvider);

//   //   stream.listen((event) {
//   //     final isUserCreateEvent =
//   //         event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create') &&
//   //             event.payload.containsValue(arg);

//   //     final isUserUpdateEvent =
//   //         event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update') &&
//   //             event.payload.containsValue(arg);

//   //     final isMessageCreateEvent =
//   //         event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
//   //             event.payload.containsValue(arg);

//   //     /// ユーザー作成イベント
//   //     if (isUserCreateEvent) {
//   //       debugPrint('USER_CREATE!');
//   //       final user = UserModel.fromMap(event.payload);
//   //       final chatUser = UserModel.toChatUser(user);
//   //       update((data) => data..$2.add(chatUser));
//   //     }

//   //     /// メッセージ更新イベント
//   //     if (isUserUpdateEvent) {
//   //       debugPrint('USER_UPDATE!');
//   //       final user = UserModel.fromMap(event.payload);
//   //       final chatUser = UserModel.toChatUser(user);
//   //       update((data) {
//   //         final index = data.$2.indexWhere((e) => e.id == chatUser.id);
//   //         return data..$2[index] = chatUser;
//   //       });
//   //     }

//   //     /// メッセージ作成イベント
//   //     if (isMessageCreateEvent) {
//   //       debugPrint('MESSAGE_CREATE!');
//   //       final message = MessageEX.fromMap(event.payload);
//   //       update((data) => data..$1.add(message));
//   //     }
//   //   });
//   // }

//   /// ユーザーリスト取得し、チャットユーザーリストに変換
//   Future<List<ChatUser>> getChatUsers() async {
//     return (await ref.read(userModelProvider.notifier).getUserModelList())
//         .map((userModel) => UserModel.toChatUser(userModel))
//         .toList();
//   }

//   /// メッセージ一覧取得
//   Future<List<Message>> getMessages({String? id}) async {
//     final messages = await _messageAPI
//         .getMessagesDocumentList(chatRoomId: arg, id: id)
//         .then(
//           (docs) => docs.documents
//               .map(
//                 (doc) => MessageEX.fromMap(doc.data),
//               )
//               .toList()
//               .reversed
//               .toList(),
//         )
//         .catchError((e) => exceptionMessage(e));

//     return messages;
//   }

//   void chatUserUpdate(RealtimeMessage event) {
//     final user = UserModel.fromMap(event.payload);
//     final chatUser = UserModel.toChatUser(user);
//     update((data) {
//       final index = data.$2.indexWhere((e) => e.id == chatUser.id);
//       return data..$2[index] = chatUser;
//     });
//   }

//   void chatUserCreate(RealtimeMessage event) {
//     final user = UserModel.fromMap(event.payload);
//     final chatUser = UserModel.toChatUser(user);
//     update((data) => data..$2.add(chatUser));
//   }

//   void addMessage(RealtimeMessage event) {
//     update((data) {
//       print('UUU');
//       return data..$1.add(MessageEX.fromMap(event.payload));
//     });
//   }

//   Future<void> addMessages() async {
//     await update((data) async {
//       final initialMessageList = data.$1;
//       final messageList25Ago = await getMessages(id: initialMessageList.first.id);

//       data.$1.insertAll(0, messageList25Ago);

//       return data;
//     });
//   }

//   /// 予期せぬエラーだあ(T ^ T) 再立ち上げしてね(>_<)
//   exceptionMessage(Object? e) {
//     String message = '''
//     予期せぬエラーだあ(T ^ T)
//     再立ち上げしてね(>_<)
//     ''';
//     if (e is AppwriteException) {
//       message = '${e.code}\n$message';
//     }
//     throw message;
//   }
// }
