import 'dart:async';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/message_ex2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final messagesProvider =
    AutoDisposeFamilyAsyncNotifierProvider<MessagesNotifier, List<Message>, String>(
  MessagesNotifier.new,
);

class MessagesNotifier extends AutoDisposeFamilyAsyncNotifier<List<Message>, String> {
  /// 最初のレコードid
  /// ページネーションで使用
  String firstId = '';

  @override
  FutureOr<List<Message>> build(arg) async {
    if (firstId.isEmpty) {
      // 最初のレコードidを取得
      firstId = await supabase
          .from('messages')
          .select('id')
          .order('created_at', ascending: true)
          .limit(1)
          .then((v) => v.firstOrNull?['id'] ?? '')
          .catchErrorEX();
    }

    // リアルタイム
    // realtimeEvent();

    // 初期データ取得
    return await supabase
        .from('messages')
        .select()
        .order('updated_at')
        .limit(2)
        .then((v) => v.map((e) => MessageEX.fromMap(e)).toList())
        .catchErrorEX();
  }

  /// リアルタイムイベント
  // void realtimeEvent() {
  //   supabase
  //       .channel('public:messages')
  //       .onPostgresChanges(
  //           event: PostgresChangeEvent.all,
  //           table: 'messages',
  //           callback: (payload) {
  //             update(
  //               (data) {
  //                 final newData = MessageEX.fromMap(payload.newRecord);
  //                 // 【INSERTイベント】
  //                 if (PostgresChangeEvent.insert == payload.eventType) {
  //                   data.insert(0, newData);
  //                   debugPrint('MESSAGE_CREATE!');
  //                 }
  //                 // 【UPDATEイベント】
  //                 else if (PostgresChangeEvent.update == payload.eventType) {
  //                   final index = data.indexWhere((e) => e.id == newData.id);
  //                   if (index != -1) data[index] = newData;
  //                   debugPrint('MESSAGE_UPDATE!');
  //                 }

  //                 return data;
  //               },
  //             );
  //           })
  //       .subscribe();
  // }

  /// ページネーション
  // Future<void> pagination() async {
  //   final messages = state.requireValue;
  //   if (messages.isEmpty || messages.last.id == firstId) return;

  //   await asyncGuard<void>(
  //     () async {
  //       final result = await supabase
  //           .from('messages')
  //           .select()
  //           .range(messages.length, messages.length + 2)
  //           .order('updated_at')
  //           .limit(2)
  //           .then((v) => v.map((e) => MessageEX.fromMap(e)).toList());

  //       messages.addAll(result);
  //     },
  //   );
  // }

  /// 更新、作成
  // Future<void> upsertState(Message chatRoomModel) async {
  //   await asyncGuard<void>(() async {
  //     await supabase.from('messages').upsert(chatRoomModel.toMap());
  //   });
  // }
}
