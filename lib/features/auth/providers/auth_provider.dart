import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/core.dart';

import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/auth/validation/auth_exception_message.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Session>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<Session> {
  Account get _account => ref.watch(appwriteAccountProvider);

  @override
  FutureOr<Session> build() async {
    final session = await _account.getSession(sessionId: 'current').then(
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
        ).catchError((e) => throw ':AUTH やり直してね( ；∀；)');
      }

      throw 'AUTH やり直してね(T ^ T)';
    });
    return session;
  }

  /// ログイン
  Future<Session> login({required String loginId, required String loginPassword}) async {
    await futureGuard(() async {
      return await _account
          .createEmailSession(
            email: '$loginId@gmail.com',
            password: loginPassword,
          )
          .catchError(
            (e) => throw authExceptionMessage(error: e),
          );
    });

    return state.value!;
  }

  /// アカウント登録
  Future<void> accountUpdate({required String loginId, required String loginPassword}) async {
    await futureGuard(() async {
      return await _account
          .updateEmail(
        email: '$loginId@gmail.com',
        password: loginPassword,
      )
          .then((_) async {
        await ref.read(userModelProvider.notifier).updateAuthUserModel(
              loginId: loginId,
              loginPassword: loginPassword,
            );
        return await login(loginId: loginId, loginPassword: loginPassword);
      }).catchError(
        (e) => throw authExceptionMessage(error: e),
      );
    });

    // if (state.hasError) {
    //   return state.error.toString();
    // }
    // return '';
  }

  Future<dynamic> logout() async {
    return ref
        .read(appwriteAccountProvider)
        .deleteSession(
          sessionId: 'current',
        )
        .then((value) => value)
        .catchError((_) => throw 'やだああああ');
  }
}
