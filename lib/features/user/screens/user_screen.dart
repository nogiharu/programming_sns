import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider2.dart';
import 'package:programming_sns/features/auth/screens/auth_update_screen.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/test_tool/test_tool.dart';

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
        authProvider,
        complete: (data) {
          return Center(
            child: Column(
              children: [
                // const TestToolcreen(),
                if (data.userMetadata?['is_anonymous'] as bool) ...[
                  Tooltip(
                    message: '登録をお勧めするよ(*^_^*)',
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(SignupScreen.path);
                      },
                      child: const Text(
                        'アカウント登録',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(LoginScreen.path);
                    },
                    child: const Text(
                      'アカウント持ってる',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(AuthUpdateScreen.path);
                    },
                    child: const Text(
                      'アカウント更新',
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
