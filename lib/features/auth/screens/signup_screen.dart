import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
  });

  static const String path = 'signup';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
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
          title: const Text('アカウント登録'),
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
                      /// 送信
                      onPressed: () async {
                        await ref.read(authProvider.notifier).accountUpdate(
                              userModel: userModel.copyWith(
                                userId: idController.text,
                                loginPassword: passwordController.text,
                                isAnonymous: false,
                              ),
                            );

                        final auth = ref.watch(authProvider);

                        if (auth.hasError) {
                          errorMessage = auth.error.toString();
                          return;
                        }

                        // ref.read(snackBarProvider({'message': '登録完了だよ(*^_^*)'}));
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
            ),
          ),
        ));
  }
}
