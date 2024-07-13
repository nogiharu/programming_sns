import 'dart:async';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/user/models/user_model2.dart';

final chatUsersProvider =
    AutoDisposeStreamNotifierProviderFamily<ChatUsersNotifier, List<ChatUser>, String>(
  ChatUsersNotifier.new,
);

class ChatUsersNotifier extends AutoDisposeFamilyStreamNotifier<List<ChatUser>, String> {
  @override
  Stream<List<ChatUser>> build(arg) {
    return Stream.fromFuture(
      supabase
          .from('chat_rooms')
          .select('member_user_ids')
          .eq('id', arg)
          .then((v) => v[0]['member_user_ids'] as List<String>),
    ).asyncExpand((memberUserIds) {
      return supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .inFilter('id', memberUserIds)
          .map((event) => event.map((e) => UserModel.toChatUser(UserModel.fromMap(e))).toList());
    });
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
  //                 final newData = ChatUserEX.fromMap(payload.newRecord);
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
}
