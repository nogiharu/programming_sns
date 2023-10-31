import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/apis/user_api.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class TestToolcreen extends ConsumerWidget {
  const TestToolcreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watchEX(
      userModelProvider,
      complete: (data) {
        return Column(
          children: [
            Text(data.name),
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
            TextButton(
              onPressed: () async {
                final messageList = await ref
                    .watch(messageAPIProvider)
                    .getMessagesDocumentList()
                    .then((docList) => docList.documents.map((doc) => doc.data).toList());

                await Future.forEach(messageList, (e) async {
                  print(e['\$id']);
                  await ref.read(messageAPIProvider).deleteMessageDocument(e['\$id']);
                });
              },
              child: const Text('メッセージ全消し'),
            ),
            TextButton(
              onPressed: () async {
                final userList = await ref.watch(userModelProvider.notifier).getUserModelList();
                await Future.forEach(userList, (user) async {
                  await ref.read(userAPIProvider).deleteUserDocument(user);
                });
              },
              child: const Text('ユーザ全消し'),
            ),
            TextButton(
              onPressed: () async {
                final user = ref.watch(userModelProvider).value;

                if (user == null) return;
                int a = 0;
                await Future.forEach(List.generate(50, (index) => index), (e) async {
                  final msg = Message(
                      id: ID.unique(),
                      createdAt: DateTime.now(),
                      message: 'ほげええええ',
                      sendBy: user.id,
                      // replyMessage: replyMessage,
                      messageType: MessageType.custom);
                  await ref.read(messageAPIProvider).createMessageDocument(msg);
                  a += e;
                  print(a);
                });
              },
              child: const Text('メッセージ50送信'),
            ),
          ],
        );
      },
    );
  }
}
