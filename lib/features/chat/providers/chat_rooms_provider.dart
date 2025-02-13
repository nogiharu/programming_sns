import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/core/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatRoomsProvider =
    AsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoomModel>>(ChatRoomsNotifier.new);

class ChatRoomsNotifier extends AsyncNotifier<List<ChatRoomModel>> {
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
          .order('updated_at', ascending: true)
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
        .limit(25)
        .then((v) => v.map((e) => ChatRoomModel.fromMap(e)).toList())
        .catchErrorEX();
  }

  Future<ChatRoomModel> getChatRoom(String id) async {
    return await supabase
        .from('chat_rooms')
        .select()
        .eq('id', id)
        .then((v) => ChatRoomModel.fromMap(v[0]))
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
                    debugPrint('【INSERT:チャットルーム】');
                  }
                  // 【UPDATEイベント】
                  else if (PostgresChangeEvent.update == payload.eventType) {
                    // 更新データを一番上に移動
                    final index = data.indexWhere((e) => e.id == newData.id);
                    if (index != -1) {
                      data
                        ..removeAt(index)
                        ..insert(0, newData);
                    }
                    debugPrint('【UPDATE:チャットルーム】');
                  }
                  return data;
                },
              );
            })
        .subscribe();
  }

  /// ページネーション
  Future<void> pagination({int limit = 25}) async {
    final chatRooms = state.requireValue;
    if (chatRooms.isEmpty || chatRooms.last.id == firstId) return;

    await asyncGuard<void>(
      () async {
        final result = await supabase
            .from('chat_rooms')
            .select()
            .range(chatRooms.length, chatRooms.length + limit)
            .order('updated_at')
            .limit(limit)
            .then((v) => v.map((e) => ChatRoomModel.fromMap(e)).toList());

        chatRooms.addAll(result);
      },
    );
  }

  /// 更新、作成
  Future<void> upsertState(ChatRoomModel chatRoomModel) async {
    await asyncGuard<void>(
      () async {
        if (chatRoomModel.name.length <= 4) {
          throw 'スレ名は5文字以上で入れてね(T ^ T)';
        }
        await supabase.from('chat_rooms').upsert(chatRoomModel.toMap());
      },
      isLoading: false,
    );
  }
}
