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
    return await getUserModel(user.userId).catchError((e) async {
      // 存在しないエラー404
      if (e is AppwriteException && e.code == 404) {
        final userCount = (await getUserModelList()).length.toString();
        // セッションID＋カウント
        final userId = user.$id.substring(user.$id.length - 4) + userCount;
        final userModel = UserModel.instance(
          documentId: user.userId,
          name: '名前はまだない',
          userId: userId,
        );
        debugPrint('ユーザー作成OK!:$userModel');
        return await _createUserModel(userModel);
      }
      throw exceptionMessage(error: e); // アロー（return省略）じゃないためthrowキーワードつけないといけない
    });
  }

  /// ユーザー取得
  /// errorCodeを取りたいためtrue
  Future<UserModel> getUserModel(String documentId) async {
    final doc = await _userAPI.getUserDocument(documentId, isDefaultError: true);
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
  }

  /// ユーザー一覧取得
  Future<List<UserModel>> getUserModelList({String? chatRoomId}) async {
    final queries = [
      Query.limit(100000),
      Query.equal('isDeleted', false),
    ];
    if (chatRoomId != null) queries.add(Query.contains('chatRoomIds', chatRoomId));

    final doc = await _userAPI.getUsersDocumentList(queries: queries);
    final userModelList = doc.documents.map((doc) => UserModel.fromMap(doc.data)).toList();

    return userModelList;
  }

  // Future<void> testError() async {
  //   await futureGuard(() async {
  //     await ref.read(storageAPIProvider).downloadImage('', '');
  //     print('AAA');
  //     return state.value!;
  //   });
  // }
}
