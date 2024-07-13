import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider2.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/chat/providers/old/messages_provider.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class TestToolcreen extends ConsumerWidget {
  const TestToolcreen({super.key});

  static const Map<String, dynamic> metaData = {
    'path': '/test',
    'label': 'test',
    'icon': Icon(Icons.person),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('text')),
      body: Center(
        heightFactor: 1,
        child: RefreshIndicator(
          onRefresh: () async {
            print('ああああああ');
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final aa = ref.read(chatRoomsProvider).requireValue;

                      final msg = Message(
                        createdAt: DateTime.now(),
                        message: 'あああああ',
                        sendBy: ref.read(userProvider).value!.id,
                        // replyMessage: replyMessage,
                        messageType: MessageType.custom, //TODO カスタム
                        chatRoomId: aa[0].id,
                        updatedAt: DateTime.now(),
                      );

                      final a =
                          await ref.read(messagesProvider(aa[0].id!).notifier).upsertState(msg);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('メッセージ作成'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      var uuid = const Uuid();
                      String newId = uuid.v4();
                      var count = await supabase.from('users').count();
                      // // print(newId);
                      // print(count);
                      final aa = await supabase.auth.signUp(
                        email: '${newId.substring(0, 8) + count.toString()}@gmail.com',
                        // email: '${newId.substring(0, 8)}@gmail.com',
                        password: newId,
                        data: {'is_anonymous': true, 'password': newId},
                      );

                      print(aa.user);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('サインイン'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    var a = supabase.auth.currentSession;
                    // print(a);
                    print(a?.user.email);
                    print(a?.user.userMetadata);
                  },
                  child: const Text('状態'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                  },
                  child: const Text('ログアウト'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .login(userId: 'hoge1', password: 'hogehoge1');
                  },
                  child: const Text('ログイン'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(chatRoomsProvider.notifier).pagination();
                  },
                  child: const Text('ページネーション'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .register(userId: 'hoge1', password: 'hogehoge1');
                  },
                  child: const Text('AUTHユーザUPDATE'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(userProvider).value!;
                    await ref
                        .read(userProvider.notifier)
                        .upsertState(user.copyWith(name: DateTime.now().toString()));
                  },
                  child: const Text('ユーザUPDATE'),
                ),
                const SizedBox(height: 10),
                ref.watchEX(
                  userProvider,
                  complete: (data) {
                    return Column(
                      children: [
                        // Text(data.chatRoomIds ?? 'a'),
                        Text(data.name),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
