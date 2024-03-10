import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/features/chat/providers/chat_room_event_provider.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_room_model_list_provider.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  onPressed: () => createThreadBottomSheet(userId: userModel.id),
                  child: const Text('スレを立てる'),
                ),
                ref.watchEX(
                  chatRoomModelListProvider,
                  isBackgroundColorNone: ref.watch(chatRoomModelListProvider).hasError,
                  complete: (chatRoom) {
                    // チャットルームイベント
                    ref.watch(chatRoomEventProvider);

                    return ListView.builder(
                      itemCount: chatRoom.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // ルームID追加 awaitはしない TODO
                            if (!userModel.chatRoomIds!.contains(chatRoom[index].id!)) {
                              final updateUserModel = userModel.copyWith(
                                updatedAt: DateTime.now(),
                              )..chatRoomIds?.add(chatRoom[index].id!);
                              // API
                              ref.read(userModelProvider.notifier).updateUserModel(updateUserModel);
                            }

                            // CHAT画面に遷移
                            context.goNamed(ChatScreen.path, extra: {
                              'label': chatRoom[index].name,
                              'chatRoomId': chatRoom[index].id,
                            });
                            // if (context.mounted) {
                            //   context.goNamed(ChatScreen.path, extra: {
                            //     'label': chatRoom[index].name,
                            //     'chatRoomId': chatRoom[index].id,
                            //   });
                            // }
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

  void createThreadBottomSheet({required String userId}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      constraints: const BoxConstraints.expand(width: double.infinity, height: 50),
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
                    .read(chatRoomModelListProvider.notifier)
                    .createChatRoom(ownerId: userId, name: textController.text)
                    .whenComplete(() {
                  // なぜかキャッチされないためwhenComplete使用
                  if (!ref.watch(chatRoomModelListProvider).hasError) {
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
