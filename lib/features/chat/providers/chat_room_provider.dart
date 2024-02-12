import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room.dart';

final chatRoomProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomNotifier, List<ChatRoom>>(ChatRoomNotifier.new);

class ChatRoomNotifier extends AutoDisposeAsyncNotifier<List<ChatRoom>> {
  ChatRoomAPI get _chatRoomAPI => ref.watch(chatRoomAPIProvider);

  @override
  FutureOr<List<ChatRoom>> build() async {
    // chatRoomEvent();
    // ref.watch(realtimeEventProvider); // TODO 他ユーザもローディングされる
    return await getChatRoomList();
  }

  void createChatRoomEvent(RealtimeMessage event) {
    debugPrint('CHAT_ROOM_CREATE!');
    update((data) {
      return data..insert(0, ChatRoom.fromMap(event.payload));
    });
  }

  Future<void> createChatRoom({required String ownerId, required String name}) async {
    await futureGuard(
      () async {
        if (name.length <= 4) throw '5文字以上で入れてね(´；ω；`)';
        return await _chatRoomAPI
            .createChatRoomDocument(ChatRoom.instance(ownerId: ownerId, name: name))
            .then((doc) => state.value!);
        // .catchError((e) => exceptionMessage(error: e));
      },
    );
  }

  Future<List<ChatRoom>> getChatRoomList() async {
    await futureGuard(
      () async {
        return await _chatRoomAPI
            .getChatRoomDocumentList()
            .then((docs) => docs.documents.map((doc) => ChatRoom.fromMap(doc.data)).toList());
        // .catchError((e) => exceptionMessage(error: e));
      },
    );

    return state.value!;
  }

  ChatRoom getChatRoom(String chatRoomId) {
    return state.value!.firstWhere((e) => e.id == chatRoomId);
  }
}
