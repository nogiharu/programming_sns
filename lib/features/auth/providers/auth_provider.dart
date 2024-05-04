import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:dart_appwrite/dart_appwrite.dart' show Users;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dart_appwrite_providers.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';

import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/common/utils.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Session>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<Session> {
  Account get _account => ref.watch(appwriteAccountProvider);
  Users get _users => ref.watch(dartAppwriteUsersProvider);
  @override
  FutureOr<Session> build() async {
    return await _account.getSession(sessionId: 'current').then(
      (session) async {
        debugPrint('アカウント取得成功！');
        return session;
      },
    ).catchError((e) async {
      // 権限エラー401
      if (e is AppwriteException && e.code == 401) {
        return await _account.createAnonymousSession().then(
          (session) {
            debugPrint('アカウント作成OK!');
            return session;
          },
        ).catchError((e) => exceptionMessage(error: e));
      }
      throw exceptionMessage(error: e); // アロー（return省略）じゃないためthrowキーワードつけないといけない
    });
  }

  /// ログイン
  Future<Session> login({
    required String loginId,
    required String loginPassword,
    UserModel? prevUserModel,
  }) async {
    return await futureGuard(() async {
      // パスワード、IDが条件を満たしていない場合、throw
      exceptionMessage(userId: loginId, loginPassword: loginPassword);

      final queries = [
        Query.equal('userId', loginId),
        Query.equal('loginPassword', loginPassword),
        Query.equal('isDeleted', false),
      ];

      await ref.read(userAPIProvider).getList(queries: queries).then((docList) async {
        // ユーザーがいない場合、throw
        if (docList.isEmpty) throw 'error';
        // authのuser削除
        await _users.delete(userId: state.requireValue.userId);
        // userModelの削除
        if (prevUserModel != null) {
          ref.read(userModelProvider.notifier).updateState(prevUserModel);
        }
      }).catchError((e) => exceptionMessage(error: e));

      // セッション作成
      return await _createSession(loginId, loginPassword, isDeleteSession: false);
    });
  }

  /// アカウント登録
  Future<void> accountUpdate({required UserModel userModel}) async {
    await futureGuard(() async {
      // パスワード、IDが条件を満たしていない場合、throw
      exceptionMessage(userId: userModel.userId, loginPassword: userModel.loginPassword);

      return await _account
          .updateEmail(
        email: '${userModel.userId}@gmail.com',
        password: userModel.loginPassword,
      )
          .then((user) async {
        // authユーザー名更新
        await _account.updateName(name: userModel.name);
        // ユーザー更新
        await ref.read(userModelProvider.notifier).updateState(userModel);
        // セッション延長
        return await _createSession(userModel.userId, userModel.loginPassword);
      }).catchError((e) => exceptionMessage(error: e));
    });
  }

  /// パスワード更新
  Future<void> loginPasswordUpdate(
      {required String newLoginPassword, required UserModel userModel}) async {
    await futureGuard(() async {
      // パスワード、IDが条件を満たしていない場合、throw
      exceptionMessage(loginPassword: newLoginPassword);

      return await _account
          .updatePassword(password: newLoginPassword, oldPassword: userModel.loginPassword)
          .then((_) async {
        await ref
            .read(userModelProvider.notifier)
            .updateState(userModel.copyWith(loginPassword: newLoginPassword));

        // セッション延長
        return await _createSession(userModel.userId, newLoginPassword);
      }).catchError((e) => exceptionMessage(error: e));
    });
  }

  Future<Session> _createSession(
    String loginId,
    String loginPassword, {
    bool isDeleteSession = true,
  }) async {
    if (isDeleteSession) await _account.deleteSession(sessionId: 'current');
    return await _account
        .createEmailPasswordSession(
          email: '$loginId@gmail.com',
          password: loginPassword,
        )
        .catchError((e) => exceptionMessage(error: e));
  }

  Future<dynamic> deleteAccount() async {
    return await ref.read(dartAppwriteUsersProvider).delete(userId: state.requireValue.userId);
  }

  Future<dynamic> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}
