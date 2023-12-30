import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/core.dart';
import 'package:programming_sns/exceptions/exception_message.dart';

import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Session>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<Session> {
  Account get _account => ref.watch(appwriteAccountProvider);

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
  Future<Session> login({required String loginId, required String loginPassword}) async {
    return await futureGuard(() async {
      exceptionMessage(loginId: loginId, loginPassword: loginPassword);
      return await _account
          .createEmailSession(
            email: '$loginId@gmail.com',
            password: loginPassword,
          )
          .catchError((e) => exceptionMessage(error: e));
    });
  }

  /// アカウント登録
  Future<void> accountUpdate({required UserModel userModel}) async {
    await futureGuard(() async {
      exceptionMessage(loginId: userModel.loginId, loginPassword: userModel.loginPassword);

      return await _account
          .updateEmail(
        email: '${userModel.loginId}@gmail.com',
        password: userModel.loginPassword,
      )
          .then((_) async {
        await ref.read(userModelProvider.notifier).updateUserModel(userModel);
        // ログインしないとセッション更新されない
        return await login(loginId: userModel.loginId, loginPassword: userModel.loginPassword);
      }).catchError((e) => exceptionMessage(error: e));
    });
  }

  /// パスワード更新
  Future<void> loginPasswordUpdate(
      {required String newLoginPassword, required UserModel userModel}) async {
    await futureGuard(() async {
      exceptionMessage(loginPassword: newLoginPassword);

      return await _account
          .updatePassword(password: newLoginPassword, oldPassword: userModel.loginPassword)
          .then((_) async {
        await ref
            .read(userModelProvider.notifier)
            .updateUserModel(userModel.copyWith(loginPassword: newLoginPassword));
        // ログインしないとセッション更新されない
        return await login(loginId: userModel.loginId, loginPassword: newLoginPassword);
      }).catchError((e) => exceptionMessage(error: e));
    });
  }

  Future<dynamic> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<dynamic> deleteAccount() async {
    await _account.deleteIdentity(identityId: state.value!.userId);
  }
}
