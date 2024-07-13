import 'dart:async';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/message_ex2.dart';
import 'package:programming_sns/features/user/models/user_model2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final textEditingControllerProvider = Provider<Map<String, TextEditingController>>((ref) {
  return {};
});

final chatControllerProvider2 =
    AutoDisposeAsyncNotifierProviderFamily<ChatControllerNotifier, ChatController, String>(
  ChatControllerNotifier.new,
);

class ChatControllerNotifier extends AutoDisposeFamilyAsyncNotifier<ChatController, String> {
  final textEditingProvider = Provider<Map<String, TextEditingController>>((ref) {
    return {};
  });

  /// 最初のレコードid
  /// ページネーションで使用
  String firstId = '';

  @override
  FutureOr<ChatController> build(arg) async {
    if (firstId.isEmpty) {
      // 最初のレコードidを取得
      firstId = await getFirstMessageId();
    }

    // 初期データ取得
    final initialMessageList = await getMessages();

    final chatUsers = await getChatUsers();

    // リアルタイム
    realtimeEvent();

    return ChatController(
      initialMessageList: initialMessageList,
      scrollController: ScrollController(),
      chatUsers: chatUsers,
    );
  }

  /// 一番最初のメッセージID取得
  /// ページネーションで使用
  Future<String> getFirstMessageId() async {
    return await supabase
        .from('messages')
        .select('id')
        .eq('chat_room_id', arg)
        .order('created_at', ascending: true)
        .limit(1)
        .then((v) => v.firstOrNull?['id'] ?? '')
        .catchErrorEX();
  }

  /// チャットユーザー取得
  Future<List<ChatUser>> getChatUsers() async {
    return await supabase.from('users').select().contains('chat_room_ids', [arg]).then(
        (v) => v.map((e) => UserModel.toChatUser(UserModel.fromMap(e))).toList());
  }

  /// メッセージ一覧取得
  Future<List<Message>> getMessages() async {
    return await supabase
        .from('messages')
        .select()
        .eq('chat_room_id', arg)
        .order('updated_at')
        .limit(25)
        .then((v) => v.reversed.map((e) => MessageEX.fromMap(e)).toList())
        .catchErrorEX();
  }

  /// リアルタイムイベント
  void realtimeEvent() {
    // 【メッセージテーブル】
    supabase
        .channel('public:messages')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'messages',
            callback: (payload) {
              update(
                (data) {
                  final newData = MessageEX.fromMap(payload.newRecord);
                  // 【INSERTイベント】
                  if (PostgresChangeEvent.insert == payload.eventType) {
                    data.addMessage(newData);
                    debugPrint('MESSAGE_CREATE!');
                  }
                  // 【UPDATEイベント】
                  else if (PostgresChangeEvent.update == payload.eventType) {
                    final index = data.initialMessageList.indexWhere((e) => e.id == newData.id);
                    if (index != -1) data.initialMessageList[index] = newData;
                    debugPrint('MESSAGE_UPDATE!');
                  }

                  return data;
                },
              );
            })
        .subscribe();

    // 【ユーザーテーブル】
    supabase
        .channel('public:users')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'users',
            callback: (payload) {
              update(
                (data) {
                  // 【UPDATEイベント】
                  if (PostgresChangeEvent.update == payload.eventType) {
                    final chatUser = UserModel.toChatUser(UserModel.fromMap(payload.newRecord));
                    final index = data.chatUsers.indexWhere((e) => e.id == chatUser.id);
                    // ユーザがいない場合は追加
                    if (index == -1) {
                      data.chatUsers.add(chatUser);
                    } else {
                      // 更新
                      data.chatUsers[index] = chatUser;
                    }
                    debugPrint('USER_UPDATE!');
                  }

                  return data;
                },
              );
            })
        .subscribe();
  }

  /// 更新、作成
  Future<void> upsertState(Message message) async {
    await asyncGuard<void>(
      () async {
        await supabase.from('messages').upsert(message.toMap());
      },
      isLoading: false,
    );
  }
}
