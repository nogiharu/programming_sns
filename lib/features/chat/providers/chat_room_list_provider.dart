import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';

final chatRoomListProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomListNotifier, List<ChatRoomModel>>(
        ChatRoomListNotifier.new);

class ChatRoomListNotifier extends AutoDisposeAsyncNotifier<List<ChatRoomModel>> {
  ChatRoomAPI get _chatRoomAPI => ref.watch(chatRoomAPIProvider);

  @override
  FutureOr<List<ChatRoomModel>> build() async {
    // chatRoomEvent();
    // ref.watch(realtimeEventProvider); // TODO 他ユーザもローディングされる
    // return await getChatRoomList();
    final queries = [
      Query.orderDesc('updatedAt'),
      Query.limit(100000), // FIXME
    ];
    return await _chatRoomAPI.getList(queries: queries, isDefaultError: true);
  }

  /// 作成イベント
  void createStateEvent(RealtimeMessage event) {
    update((data) => data..insert(0, ChatRoomModel.fromMap(event.payload)));
  }

  /// 更新されたら一番上にソート
  void updateStateEvent(RealtimeMessage event) {
    update((data) {
      final chatRoom = ChatRoomModel.fromMap(event.payload);
      final index = data.indexWhere((e) => e.documentId == chatRoom.documentId);
      return data
        ..removeAt(index)
        ..insert(0, chatRoom);
    });
  }

  Future<void> createState({required String ownerId, required String name}) async {
    await futureGuard(
      () async {
        if (name.length <= 4) throw '5文字以上で入れてね(´；ω；`)';
        return await _chatRoomAPI
            .create(ChatRoomModel.instance(ownerId: ownerId, name: name))
            .then((doc) => state.value!);
      },
    );
  }

  ChatRoomModel getState(String documentId) {
    return state.value!.firstWhere((e) => e.documentId == documentId);
  }
}
