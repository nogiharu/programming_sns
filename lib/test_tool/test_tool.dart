import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/storage_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:any_link_preview/any_link_preview.dart';

class TestToolcreen extends ConsumerWidget {
  const TestToolcreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watchEX(
      userModelProvider,
      complete: (data) {
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                  color: Colors.amber, padding: const EdgeInsets.all(5), child: Text(data.name)),
              // Text(ref.watch(authProvider).value?.email ?? 'ない'),
              TextButton(
                onPressed: () async {
                  String name;
                  if (data.name == '田島') {
                    name = '山田';
                  } else if (data.name == '山田') {
                    name = 'チコリータ';
                  } else {
                    name = '田島';
                  }

                  data = data.copyWith(name: name);
                  print(data);
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
                      sendBy: data.id,
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
