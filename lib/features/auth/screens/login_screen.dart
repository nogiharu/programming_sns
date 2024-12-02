import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/core/utils.dart';

import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/widgets/input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String path = 'login';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscureText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: ref.watchEX(
        authProvider,
        complete: (data) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InputField(
                  labelText: 'ID',
                  controller: userIdController,
                  hintText: 'IDは記号、日本語以外で半角で入力してね(^^)',
                  contentPadding: 20,
                  isLabelAnimation: false,
                ),
                const SizedBox(height: 10),
                InputField(
                  labelText: 'パスワード',
                  controller: passwordController,
                  hintText: 'パスワードは日本語以外で半角で8桁以上で入れてね(^^)',
                  contentPadding: 20,
                  isLabelAnimation: false,
                  isObscureText: isObscureText,
                  suffixIcon: IconButton(
                    icon: Icon(isObscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => isObscureText = !isObscureText),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      // ログイン処理
                      await ref.read(authProvider.notifier).login(
                            userId: userIdController.text,
                            password: passwordController.text,
                          );

                      // エラーチェック
                      if (ref.watch(authProvider).hasError) return;

                      // 遷移
                      ref.read(snackBarProvider)(message: 'ログイン完了だよ(*^_^*)');
                      if (context.mounted) context.pop();
                    },
                    child: const Text('ログイン'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
