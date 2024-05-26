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
                  final aa = await supabase.auth.signUp(
                    email: '${newId.substring(0, 8) + count.toString()}@gmail.com',
                    password: newId,
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
                var a = await supabase.auth.onAuthStateChange.first;
                // supabase.auth.onAuthStateChange.listen
                print('isAnonymous:${a.session}');
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
                try {
                  // await supabase.auth.updateUser(
                  //   UserAttributes(
                  //     data: {'name': '太郎あああoooo'},
                  //     // email: 'email@email.com',
                  //     // password: 'aaaaaaaa',
                  //   ),
                  // );
// API_EXTERNAL_URL: http://192.168.1.3:8000
// GOTRUE_SITE_URL: http://192.168.1.3:8000
                  await supabase.auth.updateUser(
                    UserAttributes(
                      data: {
                        'name': '太郎あああoooo',
                        'password': 'password',
                      },
                      email: 'email@email.com',
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
              child: const Text('ユーザ昇格'),
            ),
          ],
        ),
      ),
    );
  }
}
