import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final chatUserListProvider =
    AutoDisposeAsyncNotifierProviderFamily<ChatUserListNotifier, List<ChatUser>, String>(
  ChatUserListNotifier.new,
);

class ChatUserListNotifier extends AutoDisposeFamilyAsyncNotifier<List<ChatUser>, String> {
  @override
  FutureOr<List<ChatUser>> build(arg) async {
    return (await ref.read(userModelProvider.notifier).getUserModelList())
        .map((userModel) => UserModel.toChatUser(userModel))
        .toList();
  }
}
