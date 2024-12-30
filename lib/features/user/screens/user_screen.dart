import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/auth/screens/auth_update_screen.dart';
import 'package:programming_sns/features/auth/screens/login_screen.dart';
import 'package:programming_sns/features/auth/screens/signup_screen.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:programming_sns/widgets/input_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const Map<String, dynamic> metaData = {
    'path': '/profile',
    'label': 'プロフ',
    'icon': Icon(Icons.person),
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// リードオンリー
  bool isReadOnly = true;

  @override
  Widget build(BuildContext context) {
    // auth
    final auth = ref.watch(authProvider).value;
    if (auth == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ref.watchEX(
        userProvider,
        complete: (data) {
          final nameController = TextEditingController(text: data.name);

          final profileDetailsController = TextEditingController(text: data.profileDetails);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: InkWell(
                          mouseCursor: isReadOnly ? null : SystemMouseCursors.click,
                          onTap: isReadOnly ? null : ref.read(userProvider.notifier).uploadImage,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              data.profilePhoto ??
                                  "https://akm-img-a-in.tosshub.com/indiatoday/images/story/202103/photo-1511367461989-f85a21fda1_0_1200x768.jpeg?YVCV8xj2CmtZldc_tJAkykymqxE3fxNf&size=770:433",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ユーザーID
                            Text(data.mentionId, style: const TextStyle(color: Colors.blue)),
                            const SizedBox(height: 20),

                            // 名前
                            InputField(
                              controller: nameController,
                              borderColor: Colors.grey.shade300,
                              isMaxLines: true,
                              isReadOnly: isReadOnly,
                              labelText: '名前',
                              maxLength: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 自己紹介
                  InputField(
                    controller: profileDetailsController,
                    borderColor: Colors.grey.shade300,
                    isMaxLines: true,
                    isReadOnly: isReadOnly,
                    labelText: '自己紹介',
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: '(*^_^*)',
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => isReadOnly = !isReadOnly);
                        final newData = data.copyWith(
                          name: nameController.text,
                          profileDetails: profileDetailsController.text,
                        );
                        if (newData == data || newData.name.trim().isEmpty) return;

                        await ref.read(userProvider.notifier).upsertState(newData);
                      },
                      child: Text(isReadOnly ? 'プロフ編集' : 'プロフ編集完了'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (auth.userMetadata!['is_anonymous'] as bool) ...[
                    Tooltip(
                      message: '登録をお勧めするよ(*^_^*)',
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(SignupScreen.path);
                        },
                        child: const Text('アカウント登録'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.goNamed(LoginScreen.path);
                      },
                      child: const Text('アカウント持ってる'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        context.goNamed(AuthUpdateScreen.path);
                      },
                      child: const Text('アカウント更新'),
                    )
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
