import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/common/utils.dart';

final userProvider = AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  UserAPI get _userAPI => ref.watch(userAPIProvider);

  @override
  FutureOr<UserModel> build() async {
    final session = ref.watch(authProvider).value;
    if (session == null) return UserModel.instance();
    return await _userAPI.get(session.userId, isCustomError: false).catchError((e) async {
      // 存在しないエラー404
      if (e is AppwriteException && e.code == 404) {
        // 全ユーザ取得
        final allUsers = await getAllList();
        final sessionId = session.$id.substring(session.$id.length - 4);
        final userId = sessionId + allUsers.length.toString();

        final user = UserModel.instance(
          documentId: session.userId,
          name: '名前はまだない',
          userId: userId,
        );

        final createdUser = await _userAPI.create(user);
        debugPrint('ユーザー作成OK!:$createdUser');

        return createdUser;
      }
      throw customErrorMessage(error: e);
    });
  }

  //========================== ステート(API) START ==========================
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
  //========================== ステート(API) END ==========================

  //========================== API START ==========================
  /// ユーザー削除
  Future<UserModel> deleteUser(UserModel userModel) async {
    final deleteUser = userModel.copyWith(
      updatedAt: DateTime.now(),
      isDeleted: true,
    );
    return await _userAPI.update(deleteUser);

    // return await futureGuard(
    //   () async {
    //     final deleteUser = userModel.copyWith(
    //       updatedAt: DateTime.now(),
    //     );
    //     return await _userAPI.update(deleteUser);
    //   },
    //   isStateOnly: true,
    // );
  }

  Future<List<UserModel>> getAllList({String? chatRoomId}) async {
    final queries = [
      Query.limit(100000),
      Query.equal('isDeleted', false),
    ];

    if (chatRoomId != null) {
      queries.add(Query.contains('chatRoomIds', chatRoomId));
    }
    return await _userAPI.getList(queries: queries);
  }

  //========================== API END ==========================
}
