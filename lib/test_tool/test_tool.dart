import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider2.dart';
import 'package:programming_sns/features/chat/models/chat_room_model2.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await supabase.auth.signInAnonymously();
                  // supabase.auth.onAuthStateChange.listen((event) {event.event})
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('匿名サインイン'),
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
                await ref.read(authProvider.notifier).login(userId: 'hoge1', password: 'hogehoge1');
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
                final count = await supabase.from('chat_rooms').count();
                final a = ChatRoomModel(
                    // id: 'd05dff58-9b40-444b-b360-06acc4703fa5',
                    name: 'チャットルーム作成:$count',
                    ownerId: ref.read(userProvider).value!.id);
                await ref.read(chatRoomsProvider.notifier).upsertState(a);
              },
              child: const Text('チャットルーム作成'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final b = ref.read(chatRoomsProvider).requireValue;

                final a = ChatRoomModel(
                  id: b[0].id,
                  name: '${b[0].name}：更新',
                  ownerId: ref.read(userProvider).value!.id,
                );
                await ref.read(chatRoomsProvider.notifier).upsertState(a);
              },
              child: const Text('チャット更新作成'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(authProvider.notifier)
                    .register(userId: 'hoge1', password: 'hogehoge1');
              },
              child: const Text('ユーザUPDATE'),
            ),
            ref.watchEX(
              userProvider,
              complete: (p0) {
                return Column(
                  children: [
                    Text(p0.id),
                    Text(p0.userId),
                    Text(p0.name),
                  ],
                );
              },
            ),
            ref.watchEX(
              chatRoomsProvider,
              complete: (p0) {
                return ListView.builder(
                  itemCount: p0.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // p0[index].name
                    // print(p0[index].id);
                    return Row(
                      children: [
                        Text(p0[index].updatedAt.toString()),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(p0[index].name),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
