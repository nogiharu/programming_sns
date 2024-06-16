import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatRoomsProvider =
    AutoDisposeAsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoomModel>>(ChatRoomsNotifier.new);

class ChatRoomsNotifier extends AutoDisposeAsyncNotifier<List<ChatRoomModel>> {
  /// 最初のレコードid
  /// ページネーションで使用
  String firstId = '';

  @override
  FutureOr<List<ChatRoomModel>> build() async {
    if (firstId.isEmpty) {
      // 最初のレコードidを取得
      firstId = await supabase
          .from('chat_rooms')
          .select('id')
          .order('created_at', ascending: true)
          .limit(1)
          .then((v) => v.firstOrNull?['id'] ?? '')
          .catchErrorEX();
    }

    // リアルタイム
    realtimeEvent();

    // 初期データ取得
    return await supabase
        .from('chat_rooms')
        .select()
        .order('updated_at')
        .limit(2)
        .then((v) => v.map((e) => ChatRoomModel.fromMap(e)).toList())
        .catchErrorEX();
  }

  /// リアルタイムイベント
  void realtimeEvent() {
    supabase
        .channel('public:chat_rooms')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'chat_rooms',
            callback: (payload) {
              update(
                (data) {
                  final newData = ChatRoomModel.fromMap(payload.newRecord);
                  // 【INSERTイベント】
                  if (PostgresChangeEvent.insert == payload.eventType) {
                    data.insert(0, newData);
                    debugPrint('CHAT_ROOM_CREATE!');
                  }
                  // 【UPDATEイベント】
                  else if (PostgresChangeEvent.update == payload.eventType) {
                    final index = data.indexWhere((e) => e.id == newData.id);
                    if (index != -1) data[index] = newData;
                    debugPrint('CHAT_ROOM_UPDATE!');
                  }

                  return data;
                },
              );
            })
        .subscribe();
  }

  /// ページネーション
  Future<void> pagination() async {
    final chatRooms = state.requireValue;
    if (chatRooms.isEmpty || chatRooms.last.id == firstId) return;

    await asyncGuard<void>(
      () async {
        final result = await supabase
            .from('chat_rooms')
            .select()
            .range(chatRooms.length, chatRooms.length + 2)
            .order('updated_at')
            .limit(2)
            .then((v) => v.map((e) => ChatRoomModel.fromMap(e)).toList());

        chatRooms.addAll(result);
      },
    );
  }

  /// 更新、作成
  Future<void> upsertState(ChatRoomModel chatRoomModel) async {
    await asyncGuard<void>(() async {
      await supabase.from('chat_rooms').upsert(chatRoomModel.toMap());
    });
  }
}
