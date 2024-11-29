import 'dart:async';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/core/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:collection/src/iterable_extensions.dart';

final chatControllerProvider =
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
    ChatRoomModel? chatRoom = ref.read(chatRoomsProvider).value?.firstWhere((e) => e.id == arg);

    chatRoom ??= await ref.read(chatRoomsProvider.notifier).getChatRoom(arg);

    return await supabase
        .from('users')
        .select()
        .inFilter('id', chatRoom.memberUserIds)
        .then((v) => v.map((e) => UserModel.toChatUser(UserModel.fromMap(e))).toList());
  }

  /// メッセージ一覧取得
  Future<List<Message>> getMessages() async {
    return await supabase
        .from('messages')
        .select()
        .eq('chat_room_id', arg)
        .order('created_at')
        .limit(25)
        .then((v) => v.reversed.map((e) => MessageEX.fromMap(e)).toList())
        .catchErrorEX();
  }

  /// ページネーション
  Future<List<Message>> getNextMessages() async {
    final messageList = state.value!.initialMessageList;

    return asyncGuard(
      () async {
        return await supabase
            .from('messages')
            .select()
            .eq('chat_room_id', arg)
            .range(messageList.length, messageList.length + 25)
            .order('created_at')
            .limit(25)
            .then((v) => v.reversed.map((e) => MessageEX.fromMap(e)).toList())
            .catchErrorEX();
      },
      isLoading: false,
      isValueUpdate: false,
    );
  }

  /// リアルタイムイベント
  void realtimeEvent() {
    // 【メッセージテーブル】
    supabase
        .channel('public:messages')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'chat_room_id',
              value: arg,
            ),
            callback: (payload) {
              update(
                (data) async {
                  Message newData = MessageEX.fromMap(payload.newRecord);
                  // 【INSERTイベント】
                  if (PostgresChangeEvent.insert == payload.eventType) {
                    final isNotUser = data.chatUsers.every((e) => e.id != newData.sendBy);
                    if (isNotUser) {
                      final userModel =
                          await ref.read(userProvider.notifier).getUserModel(newData.sendBy);
                      data.chatUsers.add(UserModel.toChatUser(userModel));
                    }

                    data.initialMessageList.add(newData);
                    debugPrint('【INSERT:メッセージ】');
                  }
                  // 【UPDATEイベント】
                  else if (PostgresChangeEvent.update == payload.eventType) {
                    final index = data.initialMessageList.indexWhere((e) => e.id == newData.id);
                    if (index != -1) data.initialMessageList[index] = newData;
                    debugPrint('【UPDATE:メッセージ】');
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
