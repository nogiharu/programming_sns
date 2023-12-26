import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_room_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
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
      appBar: AppBar(
        title: const Text('チャットスレッド'),
      ),
      body: ref.watchEX(userModelProvider, complete: (userModel) {
        return Column(
          children: [
            TextButton(
              onPressed: () => createThreadBottomSheet(userId: userModel.id),
              child: const Text('スレを立てる'),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(
                    const Duration(seconds: 3),
                  );
                },
                child: ref.watchEX(
                  chatRoomProvider,
                  isBackgroundColorNone: ref.watch(chatRoomProvider).hasError,
                  complete: (chatRoom) {
                    return ListView.builder(
                      itemCount: chatRoom.length,
                      itemBuilder: (context, index) {
                        final isOwner = chatRoom[index].ownerId == userModel.id;

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
                              subtitle: isOwner
                                  ? Text(
                                      userModel.name,
                                      style: const TextStyle(color: Colors.amber),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  void createThreadBottomSheet({required String userId}) {
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
                    .createChatRoom(ownerId: userId, name: textController.text)
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
  }
}
