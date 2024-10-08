import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/screens/auth_update_screen.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

  static const Map<String, dynamic> metaData = {
    'path': '/profile',
    'label': 'プロフ',
    'icon': Icon(Icons.person),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ref.watchEX(
        userProvider,
        complete: (data) {
          final auth = ref.watch(authProvider).value;
          if (auth == null) return const Center(child: CircularProgressIndicator());

          return Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          data.profilePhoto ??
                              "https://akm-img-a-in.tosshub.com/indiatoday/images/story/202103/photo-1511367461989-f85a21fda1_0_1200x768.jpeg?YVCV8xj2CmtZldc_tJAkykymqxE3fxNf&size=770:433",
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.mentionId, style: const TextStyle(color: Colors.blue)),
                          Text(
                            data.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(data.profileDetails),
                if (auth.userMetadata!['is_anonymous'] as bool) ...[
                  Tooltip(
                    message: '登録をお勧めするよ(*^_^*)',
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(SignupScreen.path);
                      },
                      child: const Text('アカウント登録'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(LoginScreen.path);
                    },
                    child: const Text('アカウント持ってる'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(AuthUpdateScreen.path);
                    },
                    child: const Text('アカウント更新'),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
