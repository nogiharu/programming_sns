import 'dart:async';
import 'package:appwrite/appwrite.dart';
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

  /// 作成イベント
  void createChatRoomEvent(RealtimeMessage event) {
    update((data) => data..insert(0, ChatRoom.fromMap(event.payload)));
  }

  /// 更新されたら一番上にソート
  void updateChatRoomEvent(RealtimeMessage event) {
    update((data) {
      final chatRoom = ChatRoom.fromMap(event.payload);
      final index = data.indexWhere((e) => e.id == chatRoom.id);
      return data
        ..removeAt(index)
        ..insert(0, chatRoom);
    });
  }

  Future<void> createChatRoom({required String ownerId, required String name}) async {
    await futureGuard(
      () async {
        if (name.length <= 4) throw '5文字以上で入れてね(´；ω；`)';
        return await _chatRoomAPI
            .createChatRoomDocument(ChatRoom.instance(ownerId: ownerId, name: name))
            .then((doc) => state.value!);
      },
    );
  }

  Future<List<ChatRoom>> getChatRoomList() async {
    await futureGuard(
      () async {
        return await _chatRoomAPI
            .getChatRoomDocumentList()
            .then((docs) => docs.documents.map((doc) => ChatRoom.fromMap(doc.data)).toList());
      },
    );

    return state.value!;
  }

  ChatRoom getChatRoom(String chatRoomId) {
    return state.value!.firstWhere((e) => e.id == chatRoomId);
  }
}
