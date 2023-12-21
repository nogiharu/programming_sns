import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/extensions.dart';

final chatMessageListProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatMessageListNotifier, List<Message>, String>(
        ChatMessageListNotifier.new);

class ChatMessageListNotifier extends AutoDisposeFamilyAsyncNotifier<List<Message>, String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  @override
  FutureOr<List<Message>> build(arg) async {
    print('検知');
    final messages = await getMessages();
    print('messages:${messages.length}');
    return messages;
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

  void addMessage(RealtimeMessage event) {
    update((data) {
      return data..add(MessageEX.fromMap(event.payload));
    });
  }

  Future<List<Message>> addMessageList() async {
    return await update((data) async {
      final messageList25Ago = await getMessages(id: data.first.id);
      data.insertAll(0, messageList25Ago);

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
