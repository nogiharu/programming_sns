import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/extensions/extensions.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/validation/auth_exception_message.dart';
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

  Future<void> onPressed() async {
    setState(() {
      errorMessage = authExceptionMessage(
        loginId: idController.text,
        loginPassword: passwordController.text,
      );
    });

    if (errorMessage == '') {
      await ref.read(authProvider.notifier).login(
            loginId: idController.text,
            loginPassword: passwordController.text,
          );
      if (ref.watch(authProvider).hasError) {
        errorMessage = ref.watch(authProvider).error.toString();
      } else {
        if (errorMessage == '') {
          ref.read(snackBarProvider('ログイン完了だよ(*^_^*)'));
          // ignore: use_build_context_synchronously
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref.watchEX(
      userModelProvider,
      complete: (data) {
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
                        onPressed: onPressed,
                        child: const Text('ログイン'),
                      ),
                    ),

                    /// エラー
                    if (errorMessage != '')
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
      },
    );
  }
}
