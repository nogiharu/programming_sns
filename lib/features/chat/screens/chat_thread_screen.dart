import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_room_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/theme/theme_color.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key});
  static const Map<String, dynamic> metaData = {
    'path': '/chatThread',
    'label': 'スレ',
    'icon': Icon(Icons.home),
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    // textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.littleWeak,
      appBar: AppBar(
        backgroundColor: ThemeColor.main,
        title: const Text('チャットスレッド'),
      ),
      body: ref.watchEX(userModelProvider, complete: (userModel) {
        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(
              const Duration(seconds: 3),
            );
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      builder: (context) {
                        return TextFormField(
                          // maxLines: 20,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'スレ名は5文字以上で入れてね(*^_^*)',
                            contentPadding: const EdgeInsets.all(15),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await ref
                                    .read(chatRoomProvider.notifier)
                                    .createChatRoom(
                                        ownerId: userModel.id, name: textController.text)
                                    .whenComplete(() {
                                  // なぜかキャッチされないためwhenComplete使用
                                  if (!ref.watch(chatRoomProvider).hasError) {
                                    context.pop();
                                    textController.text = '';
                                    ref.read(snackBarProvider('作成完了だよ(*^_^*)'));
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          controller: textController,
                        );
                      },
                    );
                  },
                  child: const Text('スレを立てる'),
                ),
                ref.watchEX(
                  chatRoomProvider,
                  isBackColorNone: ref.watch(chatRoomProvider).hasError,
                  complete: (chatRoom) {
                    return ListView.builder(
                      itemCount: chatRoom.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // ルームID追加
                            if (!userModel.chatRoomIds!.contains(chatRoom[index].id!)) {
                              ref.read(userModelProvider.notifier).updateUserModel(
                                    userModel..chatRoomIds?.add(chatRoom[index].id!),
                                  );
                            }
                            // CHAT画面に遷移
                            context.goNamed(ChatScreen.path, extra: {
                              'label': chatRoom[index].name,
                              'chatRoomId': chatRoom[index].id,
                            });
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(chatRoom[index].name),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
