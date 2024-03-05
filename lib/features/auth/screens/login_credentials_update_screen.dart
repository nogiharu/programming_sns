import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/profile/providers/user_model_provider.dart';

class LoginCredentialsUpdateScreen extends ConsumerStatefulWidget {
  final String label;
  final bool isIdUpdate;
  const LoginCredentialsUpdateScreen({
    super.key,
    required this.label,
    required this.isIdUpdate,
  });

  static const String path = 'loginCredentialsUpdate';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginCredentialsUpdateScreenState();
}

class _LoginCredentialsUpdateScreenState extends ConsumerState<LoginCredentialsUpdateScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    passwordController.dispose();
  }

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
          title: Text(widget.label),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ID更新
                  if (widget.isIdUpdate)
                    AuthField(
                      labelText: 'ID',
                      controller: idController,
                      hintText: 'IDは記号、日本語以外で半角で入力してね(^^)',
                    )
                  else
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
                        final authNotifier = ref.read(authProvider.notifier);

                        if (widget.isIdUpdate) {
                          await authNotifier.accountUpdate(
                            userModel: userModel.copyWith(loginId: idController.text),
                          );
                        } else {
                          await authNotifier.loginPasswordUpdate(
                            userModel: userModel,
                            newLoginPassword: passwordController.text,
                          );
                        }
                        final auth = ref.watch(authProvider);

                        if (auth.hasError) {
                          errorMessage = auth.error.toString();
                          return;
                        }

                        ref.read(snackBarProvider('更新完了だよ(*^_^*)'));

                        if (context.mounted) context.pop();
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
            ),
          ),
        ));
  }
}
