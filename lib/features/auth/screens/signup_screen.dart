import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/widgets/input_field.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
  });

  static const String path = 'signup';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  bool isObscureText = false;

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
          title: const Text('アカウント登録'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputField(
                labelText: 'ユーザーID',
                controller: userIdController,
                hintText: 'ユーザーIDは記号、日本語以外で半角で入力してね(^^)',
                contentPadding: 20,
                isLabelAnimation: false,
              ),
              const SizedBox(height: 10),
              InputField(
                labelText: 'パスワード',
                controller: passwordController,
                hintText: 'パスワードは日本語以外で半角で8桁以上で入れてね(^^)',
                contentPadding: 20,
                isObscureText: isObscureText,
                isLabelAnimation: false,
                suffixIcon: IconButton(
                  icon: Icon(isObscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => isObscureText = !isObscureText),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  /// 送信
                  onPressed: () async {
                    // 登録処理
                    final authNotifier = ref.read(authProvider.notifier);

                    await authNotifier.register(
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
                    ref.read(snackBarProvider)(message: '登録完了だよ(*^_^*)');
                    if (context.mounted) context.pop();
                  },
                  child: const Text('アカウント登録'),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ));
  }
}
