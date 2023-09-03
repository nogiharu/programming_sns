import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dependencies.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    final account = ref.watch(appwriteAccountProvider);
    final user = await account.get().then(
      (user) {
        print('アカウント取得成功！');
        return user;
      },
    ).catchError((e) async {
      // 権限エラー401
      if (e is AppwriteException && e.code == 401) {
        return await account.createAnonymousSession().then(
          (_) async {
            print('アカウント仮登録成功！');
            return await account.get();
          },
        ).catchError((_) => throw '${e.code}:AUTH やり直してね( ；∀；)');
      }
      throw '${e.code}:AUTH やり直してね(T ^ T)';
    });
    return user;
  }

  void createUser() async {}

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
