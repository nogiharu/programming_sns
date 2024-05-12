// // ignore_for_file: invalid_return_type_for_catch_error

// import 'dart:async';

// import 'package:appwrite/appwrite.dart';
// import 'package:chatview/chatview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:programming_sns/apis/message_api_provider.dart';
// import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
// import 'package:programming_sns/features/chat/models/message_ex.dart';

// final textEditingControllerProvider = Provider<Map<String, TextEditingController>>((ref) {
//   return {};
// });

// final chatMessageListProvider =
//     AutoDisposeAsyncNotifierProviderFamily<ChatMessageListNotifier, List<Message>, String>(
//   ChatMessageListNotifier.new,
// );

// class ChatMessageListNotifier extends AutoDisposeFamilyAsyncNotifier<List<Message>, String> {
//   MessageAPI get _messageAPI => ref.watch(messageAPIProvider);
//   String? firstDocumentId;

//   @override
//   FutureOr<List<Message>> build(arg) async {
//     firstDocumentId = await getFirstDocumentId();
//     return await getMessages();
//   }

//   void updateMessageEvent(RealtimeMessage event) {
//     final message = MessageEX.fromMap(event.payload);
//     update((data) {
//       final index = data.indexWhere((e) => e.id == message.id);
//       return data..[index] = message;
//     });
//   }

//   /// メッセージ一覧取得
//   Future<List<Message>> getMessages({String? nextDocumentId}) async {
//     final queries = [
//       Query.orderDesc('createdAt'),
//       Query.equal('chatRoomId', arg),
//     ];
//     // idより前を取得
//     if (nextDocumentId != null) queries.add(Query.cursorAfter(nextDocumentId));

//     return await futureGuard(
//       () async {
//         return await _messageAPI.getList(queries: queries).then((e) => e.reversed.toList());
//       },
//       isStateOnly: true,
//       isLoading: false,
//     );
//   }

//   /// メッセージ作成
//   Future<void> createMessage(Message message) async {
//     await futureGuard(
//       () async {
//         return await ref.read(messageAPIProvider).create(message).then((doc) => state.requireValue);
//       },
//       isStateOnly: true,
//       isLoading: false,
//     );
//   }

//   /// 最初のメッセージ取得
//   Future<String?> getFirstDocumentId() async {
//     final queries = [
//       Query.equal('chatRoomId', arg),
//       Query.orderAsc('createdAt'),
//       Query.limit(1),
//     ];
//     return await _messageAPI.getList(queries: queries).then((docs) => docs.firstOrNull?.id);
//   }

//   /// メッセージ作成
//   Future<void> updateMessage(Message message) async {
//     await futureGuard(
//       () async {
//         return await ref.read(messageAPIProvider).update(message).then((doc) => state.requireValue);
//       },
//       isStateOnly: true,
//       isLoading: false,
//     );
//   }

//   /// メッセージ編集
//   Future<void> deleteMessage(Message message) async {
//     await futureGuard(
//       () async {
//         return await ref
//             .read(messageAPIProvider)
//             .update(message.copyWith(isDeleted: true))
//             .then((doc) => state.requireValue);
//       },
//       isStateOnly: true,
//       isLoading: false,
//     );
//   }
// }
