import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';

final chatRoomModelListProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomModelListNotifier, List<ChatRoomModel>>(
        ChatRoomModelListNotifier.new);

class ChatRoomModelListNotifier extends AutoDisposeAsyncNotifier<List<ChatRoomModel>> {
  ChatRoomAPI get _chatRoomAPI => ref.watch(chatRoomAPIProvider);

  @override
  FutureOr<List<ChatRoomModel>> build() async {
    // chatRoomEvent();
    // ref.watch(realtimeEventProvider); // TODO 他ユーザもローディングされる
    return await getChatRoomList();
  }

  /// 作成イベント
  void createChatRoomEvent(RealtimeMessage event) {
    update((data) => data..insert(0, ChatRoomModel.fromMap(event.payload)));
  }

  /// 更新されたら一番上にソート
  void updateChatRoomEvent(RealtimeMessage event) {
    update((data) {
      final chatRoom = ChatRoomModel.fromMap(event.payload);
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
            .createChatRoomDocument(ChatRoomModel.instance(ownerId: ownerId, name: name))
            .then((doc) => state.value!);
      },
    );
  }

  Future<List<ChatRoomModel>> getChatRoomList() async {
    await futureGuard(
      () async {
        return await _chatRoomAPI
            .getChatRoomDocumentList()
            .then((docs) => docs.documents.map((doc) => ChatRoomModel.fromMap(doc.data)).toList());
      },
    );

    return state.value!;
  }

  ChatRoomModel getChatRoom(String chatRoomId) {
    return state.value!.firstWhere((e) => e.id == chatRoomId);
  }
}
