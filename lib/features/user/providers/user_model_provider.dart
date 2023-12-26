import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/exceptions/exception_message.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final userModelProvider =
    AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  UserAPI get _userAPI => ref.watch(userAPIProvider);

  @override
  FutureOr<UserModel> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return UserModel.instance();
    return await _getUserModel(user.userId).catchError((e) async {
      // 存在しないエラー404
      if (e is AppwriteException && e.code == 404) {
        final userModel = UserModel.instance(
          id: user.userId,
          name: user.userId.substring(15, user.$id.length),
        );
        debugPrint('ユーザー作成OK!:$userModel');
        return await _createUserModel(userModel);
      }
      throw exceptionMessage(error: e); // アロー（return省略）じゃないためthrowキーワードつけないといけない
    });
  }

  /// ユーザー取得
  /// errorCodeを取りたいためキャッチしない
  Future<UserModel> _getUserModel(String id) async {
    final doc = await _userAPI.getUserDocument(id, isCatch: false);
    return UserModel.fromMap(doc.data);
  }

  /// ユーザー作成
  Future<UserModel> _createUserModel(UserModel userModel) async {
    final doc = await _userAPI.createUserDocument(userModel);
    return UserModel.fromMap(doc.data);
  }

  /// ユーザー更新
  Future<UserModel> updateUserModel(UserModel userModel) async {
    return await futureGuard(
      () async {
        final doc = await _userAPI.updateUserDocument(
          userModel.copyWith(updatedAt: DateTime.now()),
        );
        return UserModel.fromMap(doc.data);
      },
    );
    // return state.value!;
  }

  /// ユーザー一覧取得
  Future<List<UserModel>> getUserModelList({String? chatRoomId}) async {
    final doc = await _userAPI.getUsersDocumentList(chatRoomId: chatRoomId);
    final userModelList = doc.documents.map((doc) => UserModel.fromMap(doc.data)).toList();

    return userModelList;
  }
}
