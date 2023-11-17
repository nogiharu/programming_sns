import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/login_credentials_update_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:programming_sns/test_tool/test_tool.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Map<String, dynamic> metaData = {
    'path': '/home',
    'label': 'ホーム',
    'icon': Icon(Icons.home),
    'index': 1,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar'),
      ),
      body: ref.watchEX(
        userModelProvider,
        complete: (data) {
          return Center(
            child: Column(
              children: [
                const TestToolcreen(),
                if (data.isAnonymous) ...[
                  Tooltip(
                    message: 'セッションが一年で切れるから登録をお勧めするよ(*^_^*)',
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
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(
                        LoginCredentialsUpdateScreen.path,
                        extra: {
                          'label': 'ID更新',
                          'isIdUpdate': true,
                        },
                      );
                    },
                    child: const Text(
                      'ID更新',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(
                        LoginCredentialsUpdateScreen.path,
                        extra: {
                          'label': 'パスワード更新',
                          'isIdUpdate': false,
                        },
                      );
                    },
                    child: const Text(
                      'パスワード更新',
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
