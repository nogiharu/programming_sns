import 'package:chatview/chatview.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as da;
import 'package:dart_appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dart_appwrite_providers.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class TestToolcreen extends ConsumerWidget {
  const TestToolcreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).value;
    // print(auth?.$createdAt);
    return ref.watchEX(
      userModelProvider,
      complete: (data) {
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        ref.watch(aaa.notifier).state += 1;
                        print(ref.watch(aaa.notifier).state);
                      },
                      child: const Text('aaa')),
                  // Container(
                  //     color: Colors.amber,
                  //     padding: const EdgeInsets.all(5),
                  //     child: Text(auth?.current?.toString())),
                  Container(
                      color: Colors.amber,
                      padding: const EdgeInsets.all(5),
                      child: Text(data.name)),
                  const SizedBox(height: 10),
                  Container(
                      color: Colors.amber,
                      padding: const EdgeInsets.all(5),
                      child: Text(data.userId)),
                  const SizedBox(height: 10),
                  if (auth != null)
                    Container(
                      color: Colors.amber,
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text(auth.userId),
                          const SizedBox(height: 10),
                          Text(auth.$createdAt),
                        ],
                      ),
                    ),
                ],
              ),
              // Text(ref.watch(authProvider).value?.email ?? 'ない'),
              TextButton(
                onPressed: () async {
                  String name;
                  if (data.name == 'ポッポ') {
                    name = '山田';
                  } else if (data.name == '山田') {
                    name = 'チコリータ';
                  } else if (data.name == 'チコリータ') {
                    name = '田島';
                  } else if (data.name == '田島') {
                    name = '佐々木';
                  } else if (data.name == '佐々木') {
                    name = 'ユウジ';
                  } else if (data.name == 'ユウジ') {
                    name = 'オリジン弁当';
                  } else {
                    name = 'ポッポ';
                  }

                  data = data.copyWith(name: name);

                  final aa = await ref.read(userModelProvider.notifier).updateUserModel(data);
                  // final aaa = await ref.read(userModelProvider.notifier).getUserModelList();
                  // print(aaa);
                },
                child: const Text('名前変更'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () async {
                  if (auth != null) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
                child: const Text('セッション削除'),
              ),
              TextButton(
                onPressed: () async {
                  if (auth != null) {
                    final model.UserList a = await ref
                        .read(dartAppwriteUsersProvider)
                        .list(queries: [da.Query.limit(2000)]);

                    Future.forEach(a.users, (element) async {
                      if (auth.userId != element.$id) {
                        await ref.read(dartAppwriteUsersProvider).delete(userId: element.$id);
                      }
                    });

                    // await ref
                    //     .read(dartAppwriteUsersProvider)
                    //     .delete(userId: '65f558ac54fbf6e3fc05');
                  }
                },
                child: const Text('アカウント削除'),
              ),
              TextButton(
                onPressed: () async {
                  // final messageList = await ref
                  //     .watch(messageAPIProvider)
                  //     .getMessagesDocumentList()
                  //     .then((docList) => docList.documents.map((doc) => doc.data).toList());

                  // await Future.forEach(messageList, (e) async {
                  //   print(e['\$id']);
                  //   await ref.read(messageAPIProvider).deleteMessageDocument(e['\$id']);
                  // });
                },
                child: const Text('メッセージ全消し'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  final userList = await ref.watch(userModelProvider.notifier).getUserModelList();
                  await Future.forEach(userList, (user) async {
                    await ref.read(userAPIProvider).deleteUserDocument(user);
                  });

                  await ref.read(authProvider.notifier).logout();
                  await ref.read(authProvider.notifier).deleteAccount();
                },
                child: const Text('ユーザ全消し,アカウント削除'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () async {
                  // final kk = await ref
                  //     .watch(chatRoomAPIProvider)
                  //     .getChatRoomDocument('654824d5add3b04b9eb9');

                  // print(kk.data['messages']?.length);
                  int a = 0;
                  await Future.forEach(List.generate(10000, (index) async => index), (e) async {
                    final msg = Message(
                      // id: ID.unique(),
                      createdAt: DateTime.now(),
                      message: 'ほげええええ',
                      sendBy: data.documentId,
                      chatRoomId: '655a9b9cc6a4c4b7ddbd',
                      messageType: MessageType.custom,
                    );

                    // await ref.read(messageAPIProvider).createMessageDocument(msg);

                    print(a);
                  });
                },
                child: const Text('メッセージ50送信'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(userModelProvider.notifier)
                      .updateUserModel(data.copyWith(chatRoomIds: []));
                },
                child: const Text('チャットID削除'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  // await ref.read(userModelProvider.notifier).testError();
                },
                child: const Text('IMAGE'),
              ),
            ],
          ),
        );
      },
    );
  }
}
