import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/user_api_provider.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String path = 'login';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider).value;
    if (userModel == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AuthField(
                  labelText: 'ID',
                  controller: idController,
                  hintText: 'IDは記号、日本語以外で半角で入力してね(^^)',
                ),
                const SizedBox(height: 10),
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
                      await ref.read(authProvider.notifier).login(
                            loginId: idController.text,
                            loginPassword: passwordController.text,
                            prevUserModel: userModel.copyWith(isDeleted: true),
                          );

                      final auth = ref.watch(authProvider);

                      if (auth.hasError) {
                        errorMessage = auth.error.toString();
                        return;
                      }

                      ref.read(snackBarProvider('ログイン完了だよ(*^_^*)'));

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
        ),
      ),
    );
  }
}
