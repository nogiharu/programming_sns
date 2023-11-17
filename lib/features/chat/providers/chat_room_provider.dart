import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api.dart';
import 'package:programming_sns/extensions/async_notifier_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room.dart';

final chatRoomProvider =
    AsyncNotifierProvider<ChatRoomNotifier, List<ChatRoom>>(ChatRoomNotifier.new);

class ChatRoomNotifier extends AsyncNotifier<List<ChatRoom>> {
  ChatRoomAPI get _chatRoomAPI => ref.watch(chatRoomAPIProvider);

  @override
  FutureOr<List<ChatRoom>> build() async {
    return await getChatRoomList();
  }

  Future<void> createChatRoom({required String ownerId, required String name}) async {
    await futureGuard(
      () async {
        if (name.length <= 4) throw '5文字以上で入れてね(´；ω；`)';
        return await _chatRoomAPI
            .createChatRoomDocument(ChatRoom.instance(ownerId: ownerId, name: name))
            .then((doc) => state.value!..add(ChatRoom.fromMap(doc.data)))
            .catchError((e) => exceptionMessage(e));
      },
    );
  }

  Future<List<ChatRoom>> getChatRoomList() async {
    await futureGuard(
      () async {
        return await _chatRoomAPI
            .getChatRoomDocumentList()
            .then((docs) => docs.documents.map((doc) => ChatRoom.fromMap(doc.data)).toList())
            .catchError((e) => exceptionMessage(e));
      },
    );

    return state.value!;
  }
}
