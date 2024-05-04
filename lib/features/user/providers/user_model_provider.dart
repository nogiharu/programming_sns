import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/common/utils.dart';

final userModelProvider =
    AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  UserAPI get _userAPI => ref.watch(userAPIProvider);

  @override
  FutureOr<UserModel> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return UserModel.instance();
    return await _userAPI.get(user.userId, isDefaultError: true).catchError((e) async {
      // 存在しないエラー404
      if (e is AppwriteException && e.code == 404) {
        // 全ユーザ取得
        final users = await _userAPI.getList(queries: [
          Query.limit(100000),
          Query.equal('isDeleted', false),
        ]);

        // セッションID＋カウント
        final userId = '${user.$id.substring(user.$id.length - 4)}${users.length}';
        final userModel = UserModel.instance(
          documentId: user.userId,
          name: '名前はまだない',
          userId: userId,
        );
        debugPrint('ユーザー作成OK!:$userModel');
        return await _userAPI.create(userModel);
      }
      throw exceptionMessage(error: e);
    });
  }

  /// ユーザー更新
  Future<UserModel> updateState(UserModel userModel) async {
    return await futureGuard(
      () async {
        return await _userAPI.update(
          userModel.copyWith(updatedAt: DateTime.now()),
        );
      },
    );
  }
}
