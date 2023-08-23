import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/providers.dart';
import 'package:programming_sns/extensions/message_ex.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User>(AuthController.new);

class AuthController extends AsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    // // throw 'AAAA';
    final account = ref.read(appwriteAccountProvider);
    // String errorText;
    // // box.delete('userId');
    // try {
    //   User user;
    //   if (box.containsKey('userId')) {
    //     print("AAA");
    //     user = await account.get();
    //     if (user.$id == box.get('userId')) {
    //       print('アカウント取得成功！');
    //       return user;
    //     }
    //   }

    //   final a = await account.listSessions();
    //   print(a.sessions.first.userId);
    //   final session = await account.createAnonymousSession();
    //   print("CCC");
    //   box.put('userId', session.userId);

    //   print("DDD");
    //   user = await account.updateEmail(
    //     email: '${session.userId}@gmail.com',
    //     password: session.userId,
    //   );
    //   print('アカウント登録成功！');
    //   return user;
    // } on AppwriteException catch (_) {
    //   print(_);
    //   errorText = 'AUTH: やり直してね( ；∀；)';
    // } catch (e) {
    //   print(e);
    //   errorText = 'AUTH: やり直してね(T ^ T)';
    // }
    // throw errorText;
    return account.get().then(
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
          // (session) async {
          //   final a = await account.updateEmail(
          //     // email: '${session.userId}a',
          //     email: '${session.userId}@gmail.com',
          //     password: session.userId,
          //   );
          //   print('アカウント登録成功！');
          //   return a;
          // },
          // (_) => 必須
        ).catchError((_) => throw '${e.code}: やり直してね( ；∀；)');
      }
      throw '${e.code}: やり直してね(T ^ T)';
    });
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

  Future<Document> createMessage(Message message) async {
    final doc = await ref.read(appwriteDatabaseProvider).createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.messagesCollection,
          documentId: ID.unique(),
          data: message.toMap(),
        );
    return doc;
  }
}
