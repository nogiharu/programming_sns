import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';

import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/widgets/input_field.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String path = 'login';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider).value;
    if (userModel == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputField(
              labelText: 'ID',
              controller: userIdController,
              hintText: 'IDは記号、日本語以外で半角で入力してね(^^)',
              contentPadding: 20,
            ),
            const SizedBox(height: 10),
            InputField(
              labelText: 'パスワード',
              controller: passwordController,
              hintText: 'パスワードは日本語以外で半角で8桁以上で入れてね(^^)',
              contentPadding: 20,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () async {
                  // ログイン処理
                  final authNotifier = ref.read(authProvider.notifier);
                  await authNotifier.login(
                    userId: userIdController.text,
                    password: passwordController.text,
                  );

                  // エラーチェック
                  final authState = ref.watch(authProvider);
                  if (authState.hasError) {
                    errorMessage = authState.error.toString();
                    return;
                  }

                  // 遷移
                  ref.read(snackBarProvider)(message: 'ログイン完了だよ(*^_^*)');
                  if (context.mounted) context.pop();
                },
                child: const Text('ログイン'),
              ),
            ),

            /// エラー
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
