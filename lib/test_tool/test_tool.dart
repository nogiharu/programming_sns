import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:programming_sns/core/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
                  await supabase.auth.signInAnonymously(captchaToken: 'aaaaa');
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
                var a = supabase.auth.currentUser;
                // print(a);
                print(a?.email);
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
                final previousUser = supabase.auth.currentUser;
                print(previousUser?.id);
                await supabase.auth
                    .signInWithPassword(email: 'hoge7@gmail.com', password: 'hogehoge7')
                    .catchError((e) {
                  print(e);
                });
                print(supabase.auth.currentUser?.id);
                await supabase.auth.admin.deleteUser(previousUser!.id).catchError((e) {
                  print(e);
                });
                // await supabase.auth.refreshSession();
                // const envFile = String.fromEnvironment('env');
                // await dotenv.load(fileName: envFile);
                // final supabaseClient = SupabaseClient(
                //   dotenv.env['kUrl'] ?? '',
                //   dotenv.env['kServiceRoleKey'] ?? '',
                // );
                // await supabaseClient.auth.admin.deleteUser(previousUser!.id).catchError((e) {
                //   print(e);
                // });
                // final a = await supabaseClient.auth.admin.getUserById(previousUser.id);
                // print(a.user?.id);
              },
              child: const Text('ログイン'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // 削除できん
                await supabase.auth.admin
                    .deleteUser('94ffa4a8-2f7d-4264-84ad-9a3e334222c9')
                    .catchError((e) {
                  print(e);
                });

                // try {
                //   final a = await supabase.functions.invoke(
                //     "delete-user",
                //     body: {'id': 'b6dad234-b310-4384-8fad-856bb63325d6'},
                //   );
                //   print(a.data);
                //   // 削除後の処理など
                // } on AuthException catch (error, stackTrace) {
                //   print(error);
                // }
              },
              child: const Text('削除'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  final meta = supabase.auth.currentUser?.userMetadata;

                  await supabase.auth.updateUser(
                    UserAttributes(
                      data: {
                        ...meta!,
                        'password': 'hogehoge7',
                        'is_anonymous': false,
                      },
                      email: 'hoge7@gmail.com',
                      password: 'hogehoge7',
                    ),
                  );
                  final a = await supabase.auth.refreshSession();
                } catch (e) {
                  print(e);
                }

                // final a = await supabase.auth.signUp(
                //     email: 'hoge@gmail.com', password: '11111111', data: {'name': '太郎あああpppp'});
                // 昇格できない！！！！！！！

                // supabase.auth.signUp(password: );
              },
              child: const Text('ユーザUPDATE'),
            ),
          ],
        ),
      ),
    );
  }
}
