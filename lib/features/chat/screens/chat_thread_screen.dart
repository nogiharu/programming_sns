import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_room_list_provider.dart';
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

  late final chatRoomNotifier = ref.read(chatRoomListProvider.notifier);
  late final userNotifier = ref.read(userProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットスレッド'),
      ),
      body: ref.watchEX(userProvider, complete: (userModel) {
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
                  onPressed: () => createThreadBottomSheet(userId: userModel.documentId),
                  child: const Text('スレを立てる'),
                ),
                ref.watchEX(
                  chatRoomListProvider,
                  isBackgroundColorNone: ref.watch(chatRoomListProvider).hasError,
                  complete: (chatRoom) {
                    // チャットルームイベント
                    // ref.watch(chatRoomEventProvider);

                    return ListView.builder(
                      itemCount: chatRoom.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // ルームID追加 awaitはしない
                            final chatRoomIdContain =
                                userModel.chatRoomIds!.contains(chatRoom[index].documentId!);
                            if (!chatRoomIdContain) {
                              userModel.chatRoomIds?.add(chatRoom[index].documentId!);
                              // ステート更新
                              userNotifier.updateState(userModel);
                            }

                            // CHAT画面に遷移
                            context.go('${ChatThreadScreen.metaData['path']}/${ChatScreen.path}',
                                extra: {
                                  'label': chatRoom[index].name,
                                  'chatRoomId': chatRoom[index].documentId,
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
                await chatRoomNotifier
                    .createState(ownerId: userId, name: textController.text)
                    .whenComplete(() {
                  // なぜかキャッチされないためwhenComplete使用
                  if (!ref.watch(chatRoomListProvider).hasError) {
                    context.pop();
                    textController.text = '';
                    ref.read(snackBarProvider)(message: '作成完了だよ(*^_^*)');
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
