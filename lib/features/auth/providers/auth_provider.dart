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
  Account get _authAPI => ref.watch(appwriteAccountProvider);
  Users get _authUsersAPI => ref.watch(dartAppwriteUsersProvider);
  UserAPI get _userAPI => ref.read(userAPIProvider);
  UserModelNotifier get userNotifier => ref.read(userProvider.notifier);

  @override
  FutureOr<Session> build() async {
    return await _authAPI.getSession(sessionId: 'current').then(
      (session) async {
        debugPrint('アカウント取得成功！');
        return session;
      },
    ).catchError((e) async {
      // 権限エラー401
      if (e is AppwriteException && e.code == 401) {
        return await _authAPI.createAnonymousSession().then(
          (session) {
            debugPrint('アカウント作成OK!');
            return session;
          },
        ).catchError((e) => customErrorMessage(error: e));
      }
      throw customErrorMessage(error: e);
    });
  }

  /// ログイン
  /// TODO ロールバックできない
  Future<Session> login({
    required String userId,
    required String password,
    required UserModel userModel,
  }) async {
    return await futureGuard(
      () async {
        // パスワード、IDが条件を満たしていない場合 例外を投げる
        customErrorMessage(userId: userId, password: password);

        // ユーザの存在チェック
        final users = await _userAPI.getList(queries: [
          Query.equal('userId', userId),
          Query.equal('password', password),
          Query.equal('isDeleted', false),
        ]);

        if (users.isEmpty) throw 'ユーザーがいないよ(>_<)';

        // 現在ログイン中の匿名ユーザを削除 ※削除しないとログインできない
        await _deleteCurrentUser(prevUser: userModel);

        // ログイン（セッション作成）
        // _deleteCurrentUser で既にセッションを削除しているため isDeleteSession はfalseにする
        return await _createSession(userId, password, isDeleteSession: false);
      },
      isCustomError: true,
    );
  }

  /// アカウント登録 or 更新
  /// TODO ロールバックできない
  Future<void> registerOrUpdate({required UserModel userModel}) async {
    await futureGuard(
      () async {
        // パスワード、IDが条件を満たしていない場合 例外を投げる
        customErrorMessage(userId: userModel.userId, password: userModel.password);

        // 登録or更新
        await _authAPI.updateEmail(
          email: '${userModel.userId}@gmail.com',
          password: userModel.password,
        );
        // authユーザー名更新
        await _authAPI.updateName(name: userModel.name);
        // ユーザー更新
        await userNotifier.updateState(userModel);

        // セッション延長
        return await _createSession(userModel.userId, userModel.password);
      },
      isCustomError: true,
    );
  }

  /// パスワード更新
  /// TODO ロールバックできない
  Future<void> passwordUpdate({required String newPassword, required UserModel userModel}) async {
    await futureGuard(
      () async {
        // パスワード、IDが条件を満たしていない場合 例外を投げる
        customErrorMessage(password: newPassword);
        // authパスワード更新
        await _authAPI.updatePassword(
          password: newPassword,
          oldPassword: userModel.password,
        );
        // ユーザーパスワード更新
        await userNotifier.updateState(userModel.copyWith(password: newPassword));

        // セッション延長
        return await _createSession(userModel.userId, newPassword);
      },
      isCustomError: true,
    );
  }

  /// 現在ログイン中のユーザを削除
  /// Authユーザとユーザの削除
  /// TODO ロールバックできない
  Future<void> _deleteCurrentUser({required UserModel prevUser}) async {
    // 現在ログイン中の匿名Authユーザを削除
    final currentAuthId = state.requireValue.userId;
    await _authUsersAPI.delete(userId: currentAuthId);
    // 現在ログイン中のユーザを削除
    await userNotifier.deleteUser(prevUser);
  }

  /// TODO ロールバックできない
  Future<Session> _createSession(
    String userId,
    String password, {
    bool isDeleteSession = true,
  }) async {
    if (isDeleteSession) await _authAPI.deleteSession(sessionId: 'current');
    return await _authAPI.createEmailPasswordSession(
      email: '$userId@gmail.com',
      password: password,
    );
  }

  Future<dynamic> deleteAccount() async {
    return await ref.read(dartAppwriteUsersProvider).delete(userId: state.requireValue.userId);
  }

  Future<dynamic> logout() async {
    await _authAPI.deleteSession(sessionId: 'current');
  }
}
