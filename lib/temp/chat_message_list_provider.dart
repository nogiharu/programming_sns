// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final firstChatMessageProvider = FutureProviderFamily<Message, String>((ref, chatRoomId) async {
  return ref.read(chatMessageListProvider(chatRoomId).notifier).getFirstMessage();
});

final textEditingControllerProvider = Provider<Map<String, TextEditingController>>((ref) {
  return {};
});

final chatMessageListProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatMessageListNotifier, List<Message>, String>(
  ChatMessageListNotifier.new,
);

class ChatMessageListNotifier extends AutoDisposeFamilyAsyncNotifier<List<Message>, String> {
  MessageAPI get _messageAPI => ref.watch(messageAPIProvider);

  @override
  FutureOr<List<Message>> build(arg) async {
    return await getMessages();
  }

  void updateMessageEvent(RealtimeMessage event) {
    final message = MessageEX.fromMap(event.payload);
    update((data) {
      final index = data.indexWhere((e) => e.id == message.id);
      return data..[index] = message;
    });
  }

  /// メッセージ一覧取得
  Future<List<Message>> getMessages({String? before25MessageId, List<String>? queries}) async {
    if (queries == null) {
      queries = [
        Query.orderDesc('createdAt'),
        Query.equal('chatRoomId', arg),
        Query.limit(25),
      ];
      // idより前を取得
      if (before25MessageId != null) queries.add(Query.cursorAfter(before25MessageId));
    }

    return await futureGuard(() async {
      final messages = await _messageAPI.getList(queries: queries).then(
            (docs) => docs.reversed.toList(),
          );

      return messages;
    });
  }

  /// メッセージ作成
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> createMessage(Message message) async {
    await ref.read(messageAPIProvider).create(message).catchError(ref.read(showDialogProvider));
  }

  /// 最初のメッセージ取得
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<Message> getFirstMessage() async {
    final queries = [
      Query.equal('chatRoomId', arg),
      Query.orderAsc('createdAt'),
      Query.limit(1),
    ];
    final messages = await _messageAPI
        .getList(queries: queries)
        .then((docs) => docs.first)
        .catchError(ref.read(showDialogProvider));

    return messages;
  }

  /// メッセージ作成
  /// FIXME state.valueではない値を返したいためfutureGuard使えない
  Future<void> updateMessage(Message message) async {
    await ref.read(messageAPIProvider).update(message).catchError(ref.read(showDialogProvider));
  }
}
