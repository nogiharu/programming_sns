import 'dart:async';

import 'package:appwrite/appwrite.dart';
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

  /// 予期せぬエラーだあ(T ^ T) 再立ち上げしてね(>_<)
  exceptionMessage(Object? e) {
    String message = '''
    予期せぬエラーだあ(T ^ T)
    再立ち上げしてね(>_<)
    ''';
    if (e is AppwriteException) {
      message = '${e.code}\n$message';
    }
    throw message;
  }
}
