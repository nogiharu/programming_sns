import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uuid/uuid.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User> {
  final _authChangeProvider = StreamProvider((ref) => supabase.auth.onAuthStateChange);

  @override
  FutureOr<User> build() async {
    // authの変更を監視
    // ref.watch(authChangeStateProvider);
    // await supabase.auth.refreshSession();

    // あればそのまま返す
    if (supabase.auth.currentUser != null) return supabase.auth.currentUser!;

    try {
      final count = await supabase.from('users').count();
      final uuid = const Uuid().v4();
      final newUserId = uuid.substring(0, 8) + count.toString();

      final res = await supabase.auth.signUp(
        email: '$newUserId@email.com',
        password: uuid,
        data: {'is_anonymous': true, 'password': uuid, 'userId': newUserId},
      );

      return res.session!.user;
    } catch (e) {
      throw customError(error: e);
    }
  }

  Future<User> login({required String userId, required String password}) async {
    return await futureGuard(
      () async {
        // ユーザID、パスワードが登録条件を満たしていない場合スロー
        customError(userId: userId, password: password);

        // 現在の匿名ユーザを取得
        final previous = state.requireValue;

        // ログイン
        await supabase.auth.signInWithPassword(
          email: '$userId@email.com',
          password: password,
        );
        // セッション再作成
        final res = await supabase.auth.refreshSession();

        // 匿名ログインを削除
        await supabase.functions.invoke("delete-user", body: {'id': previous.id});

        return res.user!;
      },
    );
  }

  Future<User> register({required String userId, required String password}) async {
    return await futureGuard(
      () async {
        // ユーザID、パスワードが登録条件を満たしていない場合スロー
        customError(userId: userId, password: password);

        // 更新
        await supabase.auth.updateUser(
          UserAttributes(
            data: {'password': password, 'is_anonymous': false},
            email: '$userId@email.com',
            password: password,
          ),
        );
        // セッション再作成
        final res = await supabase.auth.refreshSession();

        return res.user!;
      },
    );
  }
}
