import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notifications_provider.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class TestToolcreen extends ConsumerStatefulWidget {
  const TestToolcreen({super.key});

  static const Map<String, dynamic> metaData = {
    'path': '/test',
    'label': 'test',
    'icon': Icon(Icons.person),
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TestToolcreenState();
}

class _TestToolcreenState extends ConsumerState<TestToolcreen> {
  String imageStr = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('text')),
      body: Center(
        heightFactor: 1,
        child: RefreshIndicator(
          onRefresh: () async {
            print('ああああああ');
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final aa = ref.read(chatRoomsProvider).requireValue;

                      final msg = Message(
                        createdAt: DateTime.now(),
                        message: 'あああああ',
                        sendBy: ref.read(userProvider).value!.id,
                        // replyMessage: replyMessage,
                        messageType: MessageType.custom, //TODO カスタム
                        chatRoomId: aa[0].id,
                        updatedAt: DateTime.now(),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('メッセージ作成'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final count = await supabase.from('users').count();
                      final uuid = const Uuid().v4();
                      final newUserId = uuid.substring(0, 8) + count.toString();
                      print('来たかな？１');
                      final result = await supabase.auth.signUp(
                        email: '$newUserId@email.com',
                        password: uuid,
                        data: {'is_anonymous': true, 'password': uuid, 'userId': newUserId},
                      );

                      print(result.user);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('サインイン'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final aa = await supabase
                        .schema('auth')
                        .from('users')
                        .select()
                        .eq('id', supabase.auth.currentUser!.id);
                    print(aa);

                    // var a = supabase.auth.currentSession;
                    // // print(a);
                    // print(a?.user.email);
                    // print(a?.user.userMetadata);
                  },
                  child: const Text('状態'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                  },
                  child: const Text('ログアウト'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .login(userId: 'hoge1', password: 'hogehoge1');
                  },
                  child: const Text('ログイン'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(chatRoomsProvider.notifier).pagination();
                  },
                  child: const Text('ページネーション'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .register(userId: 'hoge1', password: 'hogehoge1');
                  },
                  child: const Text('AUTHユーザUPDATE'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(userProvider).value!;
                    await ref
                        .read(userProvider.notifier)
                        .upsertState(user.copyWith(name: DateTime.now().toString()));
                  },
                  child: const Text('ユーザUPDATE'),
                ),
                const SizedBox(height: 10),
                ref.watchEX(
                  userProvider,
                  complete: (data) {
                    return Column(
                      children: [
                        // Text(data.chatRoomIds ?? 'a'),
                        Text(data.name),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(userProvider).requireValue;
                    String name = user.name;
                    if (name == '名前はまだない') {
                      name = '佐々木';
                    } else if (name == '佐々木') {
                      name = 'チコリータ';
                    } else if (name == 'チコリータ') {
                      name = '伊藤';
                    } else if (name == '伊藤') {
                      name = '谷口';
                    } else if (name == '谷口') {
                      name = 'エンジニア';
                    } else if (name == 'エンジニア') {
                      name = '矢島';
                    } else if (name == '矢島') {
                      name = '安藤';
                    } else if (name == '安藤') {
                      name = 'ヨモギ';
                    } else if (name == 'ヨモギ') {
                      name = '深夜';
                    } else if (name == '深夜') {
                      name = 'シェリルノーム';
                    } else if (name == 'シェリルノーム') {
                      name = '名前はまだない';
                    }

                    await ref.read(userProvider.notifier).upsertState(user.copyWith(name: name));
                  },
                  child: const Text('名前変更'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    print(ref.read(userProvider).value!.id);
                    await ref
                        .read(notificationsProvider.notifier)
                        .upsertState(NotificationModel.instance(
                          userId: ref.read(userProvider).value!.id,
                          chatRoomId: ref.read(userProvider).value!.id,
                        ));
                  },
                  child: const Text('通知'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    print(image);

                    // final s3 = S3(
                    //   region: 'auto', // R2では'auto'を使用
                    //   endpointUrl:
                    //       'https://58baa1400a6b1109671d50f748d28f97.r2.cloudflarestorage.com',
                    //   credentials: AwsClientCredentials(
                    //     accessKey: 'a18f5d7c39a0b913af15d79d8fa7b6bc',
                    //     secretKey:
                    //         '2c6a1b8e65fe5f546e11ef4349791c2221a169f0cc792144cff96253fd33297b',
                    //   ),
                    // );
                    // final aa = await s3.putObject(
                    //     bucket: 'messages', key: image!.name, body: (await image.readAsBytes()));

                    // 匿名ログインを削除
//                     final aaa = await supabase.functions.invoke("upload-image", body: {
//                       'bucket': 'programming-sns',
//                       'key': 'test/${image.name}',
//                       'body': (await image.readAsBytes())
//                     });
//                     imageStr = aaa.data['url'];
// // アップロードしてURL返却まで！！！！！！！！！１１１
//                     print('来たかな？３${aaa.data}');
                    setState(() {});
                  },
                  child: const Text('UPLOAD'),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: InteractiveViewer(
                    // minScale: 0.1, // より小さな値に設定
                    // maxScale: 1.0, // 最大でも元のサイズまで
                    // boundaryMargin: const EdgeInsets.all(20.0), // ビューポートの余白を設定
                    // constrained: false, // 親のサイズに制約されないようにする
                    child: Image.network(
                      fit: BoxFit.contain, // fitHeightからcontainに変更
                      imageStr,
                    ),
                  ),
                  onTap: () async {
                    await previewImage(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 'https://messages.58baa1400a6b1109671d50f748d28f97.r2.cloudflarestorage.com/test/anzu.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=a18f5d7c39a0b913af15d79d8fa7b6bc%2F20241110%2Fauto%2Fs3%2Faws4_request&X-Amz-Date=20241110T005140Z&X-Amz-Expires=3600&X-Amz-Signature=2e9352593d208ab5e656c79adc77f712a59b6bf76a148dd1f82e8c98b5fcb420&X-Amz-SignedHeaders=host&x-id=GetObject';

                    final Uri parsedUrl = Uri.parse(imageStr);
                    if (await canLaunchUrl(parsedUrl)) {
                      await launchUrl(parsedUrl);
                    } else {
                      throw 'Could not launch $imageStr';
                    }
                  },
                  child: const Text('ダウンロード'),
                ),
                ref.watchEX(
                  userProvider,
                  complete: (p0) {
                    return Text(p0.name);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 画像プレビュー
  Future<void> previewImage(BuildContext context) async {
    const url = 'https://pub-fc01b0945155426b885cf534d131de7d.r2.dev/test/anzu.jpeg';

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => context.pop(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.1,
                maxScale: 5,
                child: Image.network(imageStr),
              ),
            ],
          ),
        );
      },
    );
  }
}
