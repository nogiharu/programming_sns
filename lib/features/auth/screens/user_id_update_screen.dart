import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/widgets/auth_field.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class UserIdUpdateScreen extends ConsumerStatefulWidget {
  const UserIdUpdateScreen({
    super.key,
  });

  static const String path = 'userIdUpdate';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserIdUpdateScreenState();
}

class _UserIdUpdateScreenState extends ConsumerState<UserIdUpdateScreen> {
  final userIdController = TextEditingController();

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userProvider).value;
    if (userModel == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    userIdController.text = userModel.userId;

    return Scaffold(
        appBar: AppBar(
          title: const Text('ユーザーID更新'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ID更新
              AuthField(
                labelText: 'ユーザーID',
                controller: userIdController,
                hintText: 'ユーザーIDは記号、日本語以外で半角で入力してね(^^)',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // 更新処理
                    final authNotifier = ref.read(authProvider.notifier);
                    await authNotifier.registerOrUpdate(
                      userModel: userModel.copyWith(userId: userIdController.text),
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
