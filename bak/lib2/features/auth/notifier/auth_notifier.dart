import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../lib2/core/providers.dart';
import '../../../../lib2/main.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    final account = ref.read(appwriteAccountProvider);
    // throw 'AAA';
    String errorText;
    // box.delete('userId');
    try {
      User user;
      if (box.containsKey('userId')) {
        user = await account.get();
        if (user.$id == box.get('userId')) {
          print('アカウント取得成功！');
          return user;
        }
      }
      final session = await account.createAnonymousSession();
      box.put('userId', session.userId);
      user = await account.updateEmail(
        email: '${session.userId}@gmail.com',
        password: session.userId,
      );
      print('アカウント登録成功！');
      return user;
    } on AppwriteException catch (_) {
      print(_);
      errorText = 'AUTH: やり直してね( ；∀；)';
    } catch (e) {
      print(e);
      errorText = 'AUTH: やり直してね(T ^ T)';
    }
    throw errorText;
    // return account.get().then(
    //   (user) {
    //     print('アカウント取得成功！');
    //     return user;
    //   },
    // ).catchError((e) async {
    //   // 権限エラー401
    //   if (e is AppwriteException && e.code == 401) {
    //     return await account.createAnonymousSession().then(
    //       (session) async {
    //         final a = await account.updateEmail(
    //           // email: '${session.userId}a',
    //           email: '${session.userId}@gmail.com',
    //           password: session.userId,
    //         );
    //         print('アカウント登録成功！');
    //         return a;
    //       },
    //       // (_) => 必須
    //     ).catchError((_) => throw 'AUTH: やり直してね( ；∀；)');
    //   }
    //   throw 'AUTH: やり直してね(T ^ T)';
    // });

    // throw 'AA';
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
