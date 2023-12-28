import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/extensions.dart';

final firstChatMessageProvider = FutureProviderFamily<Message, String>((ref, chatRoomId) async {
  return ref.read(chatMessageListProvider(chatRoomId).notifier).getFirstMessage();
});

final chatMessageListProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatMessageListNotifier, List<Message>, String>(
        ChatMessageListNotifier.new);

class ChatMessageListNotifier extends AutoDisposeFamilyAsyncNotifier<List<Message>, String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  @override
  FutureOr<List<Message>> build(arg) async {
    return await getMessageList();
  }

  /// メッセージ一覧取得
  Future<List<Message>> getMessageList({String? id}) async {
    return await _messageAPI.getMessagesDocumentList(chatRoomId: arg, id: id).then((docs) {
      return docs.documents
          .map(
            (doc) => MessageEX.fromMap(doc.data),
          )
          .toList()
          .reversed
          .toList();
    });
  }

  /// 最初のメッセージ取得
  Future<Message> getFirstMessage() async {
    final messages = await _messageAPI
        .getFirstMessageDocument(
          chatRoomId: arg,
        )
        .then((docs) => docs.documents.map((doc) => MessageEX.fromMap(doc.data)).first);

    return messages;
  }

  void addMessage(RealtimeMessage event) {
    update((data) => data..add(MessageEX.fromMap(event.payload)));
  }
}
