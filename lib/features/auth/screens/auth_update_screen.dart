import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/widgets/input_field.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class AuthUpdateScreen extends ConsumerStatefulWidget {
  const AuthUpdateScreen({
    super.key,
  });

  static const String path = 'update';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthUpdateScreenState();
}

class _AuthUpdateScreenState extends ConsumerState<AuthUpdateScreen> {
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscureText = false;

  @override
  void initState() {
    userIdController.text = ref.read(userProvider).value?.mentionId ?? '';
    passwordController.text = ref.read(authProvider).value?.userMetadata?['password'] ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザーID更新'),
      ),
      body: ref.watchEX(
        authProvider,
        complete: (data) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ID更新
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
                      // 更新処理
                      await ref.read(authProvider.notifier).register(
                            userId: userIdController.text,
                            password: passwordController.text,
                          );

                      // エラーチェック
                      if (ref.watch(authProvider).hasError) return;

                      // 遷移
                      if (context.mounted) context.pop();
                      ref.read(snackBarProvider)(message: '更新完了だよ(*^_^*)');
                    },
                    child: const Text('更新'),
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
