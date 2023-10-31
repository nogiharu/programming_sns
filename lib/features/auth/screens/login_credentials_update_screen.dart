import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/validation/auth_exception_message.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

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

  /// ID更新
  Future<void> loginIdUpdate(UserModel userModel) async {
    setState(() {
      errorMessage = authExceptionMessage(
        loginId: idController.text,
        loginPassword: userModel.loginPassword,
      );
    });
    if (errorMessage == '') {
      await ref.read(authProvider.notifier).accountUpdate(
            loginId: idController.text,
            loginPassword: userModel.loginPassword,
          );
    }
  }

  /// Password更新
  Future<void> loginPasswordUpdate(UserModel userModel) async {
    setState(() {
      errorMessage = authExceptionMessage(
        loginId: userModel.loginId,
        loginPassword: passwordController.text,
      );
    });

    if (errorMessage == '') {
      await ref.read(authProvider.notifier).accountUpdate(
            loginId: userModel.loginId,
            loginPassword: passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(userModelProvider).value == null) {
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
                  ref.watchEX(
                    userModelProvider,
                    complete: (userModel) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (widget.isIdUpdate) {
                              await loginIdUpdate(userModel);
                            } else {
                              await loginPasswordUpdate(userModel);
                            }

                            if (ref.watch(authProvider).hasError) {
                              errorMessage = ref.watch(authProvider).error.toString();
                            }
                            if (errorMessage == '') {
                              ref.read(snackBarProvider('更新完了だよ(*^_^*)'));
                              // ignore: use_build_context_synchronously
                              context.pop();
                            }
                          },
                          child: const Text('更新'),
                        ),
                      );
                    },
                  ),
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
        ));
  }
}
