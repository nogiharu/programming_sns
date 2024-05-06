import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class PasswordUpdateScreen extends ConsumerStatefulWidget {
  const PasswordUpdateScreen({
    super.key,
  });

  static const String path = 'passwordUpdate';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends ConsumerState<PasswordUpdateScreen> {
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

    passwordController.text = userModel.password;

    return Scaffold(
        appBar: AppBar(
          title: const Text('パスワード更新'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthField(
                labelText: 'パスワード',
                controller: passwordController,
                hintText: 'パスワードは日本語以外で半角で8桁以上で入れてね(^^)',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // 更新
                    final authNotifier = ref.read(authProvider.notifier);
                    await authNotifier.passwordUpdate(
                      userModel: userModel,
                      newPassword: passwordController.text,
                    );

                    // エラーチェック
                    final auth = ref.watch(authProvider);
                    if (auth.hasError) {
                      errorMessage = auth.error.toString();
                      return;
                    }

                    // 遷移
                    if (context.mounted) context.pop();
                    ref.read(snackBarProvider)(message: '更新完了だよ(*^_^*)');
                  },
                  child: const Text('更新'),
                ),
              ),
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
