// ignore_for_file: invalid_return_type_for_catch_error

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final chatUserListProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatUserListNotifier, List<ChatUser>, String>(
  ChatUserListNotifier.new,
);

class ChatUserListNotifier extends AutoDisposeFamilyAsyncNotifier<List<ChatUser>, String> {
  @override
  FutureOr<List<ChatUser>> build(arg) async {
    return await ref.watch(userAPIProvider).getList(queries: [
      Query.limit(100000),
      Query.equal('isDeleted', false),
      Query.contains('chatRoomIds', arg),
    ]).then((users) => users.map((user) => UserModel.toChatUser(user)).toList());
  }

  void updateChatUser(RealtimeMessage event) {
    final user = UserModel.fromMap(event.payload);
    final chatUser = UserModel.toChatUser(user);
    update((data) {
      final index = data.indexWhere((e) => e.id == chatUser.id);
      // ユーザがいない場合は追加
      if (index == -1) {
        data.add(chatUser);
      } else {
        // 更新
        data[index] = chatUser;
      }
      return data;
    });
  }
}
