import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/chat_room_api_provider.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/realtime_event_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';

final chatRoomListProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomListNotifier, List<ChatRoomModel>>(
        ChatRoomListNotifier.new);

class ChatRoomListNotifier extends AutoDisposeAsyncNotifier<List<ChatRoomModel>> {
  ChatRoomAPI get _chatRoomAPI => ref.watch(chatRoomAPIProvider);
  String? firstDocumentId;

  @override
  FutureOr<List<ChatRoomModel>> build() async {
    // チャットルームイベント
    realtimeEvent();

    /// 最初のデータ取得
    final firstList = await _chatRoomAPI.getList(queries: [
      Query.orderAsc('updatedAt'),
      Query.limit(1),
    ]);
    firstDocumentId = firstList.firstOrNull?.documentId;

    return await getAllList();
  }

  //========================== ステート(API) START ==========================

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

  Future<void> addStateList() async {
    final data = state.requireValue;

    if (data.isEmpty || firstDocumentId == data.last.documentId) return;

    await futureGuard(
      () async {
        final nextList = await getAllList(nextPagenationId: data.last.documentId);

        return state.requireValue..addAll(nextList);
      },
      isLoading: false,
    );
  }
  //========================== ステート(API) END ==========================

  //========================== API START ==========================

  Future<List<ChatRoomModel>> getAllList({String? nextPagenationId}) async {
    final queries = [Query.orderDesc('updatedAt')];

    if (nextPagenationId != null) {
      queries.add(Query.cursorAfter(nextPagenationId));
    }

    return await _chatRoomAPI.getList(queries: queries);
  }

  ChatRoomModel getState(String documentId) {
    return state.value!.firstWhere((e) => e.documentId == documentId);
  }

  //========================== API END ==========================

  //========================== イベント START ==========================

  void realtimeEvent() {
    ref.listen(realtimeEventProvider, (previous, next) {
      next.whenOrNull(
        data: (event) {
          final isChatRoomCreateEvent =
              event.events.contains('${AppwriteConstants.kChatRoomDocmentsChannels}.*.create');
          final isChatRoomUpdateEvent =
              event.events.contains('${AppwriteConstants.kChatRoomDocmentsChannels}.*.update');

          /// チャットルーム作成イベント
          if (isChatRoomUpdateEvent) {
            debugPrint('CHAT_ROOM_UPDATE!');
            _updateStateEvent(event);
          }

          /// チャットルーム作成イベント
          if (isChatRoomCreateEvent) {
            debugPrint('CHAT_ROOM_CREATE!');
            _createStateEvent(event);
          }
        },
      );
    });
  }

  /// 作成イベント
  void _createStateEvent(RealtimeMessage event) {
    update((data) => data..insert(0, ChatRoomModel.fromMap(event.payload)));
  }

  /// 更新されたら一番上にソート
  void _updateStateEvent(RealtimeMessage event) {
    update((data) {
      final chatRoom = ChatRoomModel.fromMap(event.payload);
      final index = data.indexWhere((e) => e.documentId == chatRoom.documentId);
      return data
        ..removeAt(index)
        ..insert(0, chatRoom);
    });
  }

  //========================== イベント END ==========================
}
