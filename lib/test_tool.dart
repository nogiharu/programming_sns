import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notifications_provider.dart';
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
                      final count = await supabase.from('users').count();
                      final uuid = const Uuid().v4();
                      final newUserId = uuid.substring(0, 8) + count.toString();
                      print('来たかな？１');
                      final result = await supabase.auth.signUp(
                        email: '$newUserId@email.com',
                        password: uuid,
                        data: {'is_anonymous': true, 'password': uuid, 'userId': newUserId},
                      );

                      print(result.user);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('サインイン'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final aa = await supabase
                        .schema('auth')
                        .from('users')
                        .select()
                        .eq('id', supabase.auth.currentUser!.id);
                    print(aa);

                    // var a = supabase.auth.currentSession;
                    // // print(a);
                    // print(a?.user.email);
                    // print(a?.user.userMetadata);
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
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(userProvider).requireValue;
                    String name = user.name;
                    if (name == '名前はまだない') {
                      name = '佐々木';
                    } else if (name == '佐々木') {
                      name = 'チコリータ';
                    } else if (name == 'チコリータ') {
                      name = '伊藤';
                    } else if (name == '伊藤') {
                      name = '谷口';
                    } else if (name == '谷口') {
                      name = 'エンジニア';
                    } else if (name == 'エンジニア') {
                      name = '矢島';
                    } else if (name == '矢島') {
                      name = '安藤';
                    } else if (name == '安藤') {
                      name = 'ヨモギ';
                    } else if (name == 'ヨモギ') {
                      name = '深夜';
                    } else if (name == '深夜') {
                      name = 'シェリルノーム';
                    } else if (name == 'シェリルノーム') {
                      name = '名前はまだない';
                    }

                    await ref.read(userProvider.notifier).upsertState(user.copyWith(name: name));
                  },
                  child: const Text('名前変更'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    print(ref.read(userProvider).value!.id);
                    await ref
                        .read(notificationsProvider.notifier)
                        .upsertState(NotificationModel.instance(
                          userId: ref.read(userProvider).value!.id,
                          chatRoomId: ref.read(userProvider).value!.id,
                        ));
                  },
                  child: const Text('通知'),
                ),
                ref.watchEX(
                  userProvider,
                  complete: (p0) {
                    return Text(p0.name);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
