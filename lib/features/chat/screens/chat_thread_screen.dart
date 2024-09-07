import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

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
  final scrollController = ScrollController();
  final textController = TextEditingController();

  late final chatRoomsNotifier = ref.read(chatRoomsProvider.notifier);
  late final userNotifier = ref.read(userProvider.notifier);

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    super.initState();
  }

  Future<void> scrollListener() async {
    // await中にスクロールしたくないため消す
    scrollController.removeListener(scrollListener);
    if (scrollController.position.maxScrollExtent == scrollController.position.pixels) {
      await chatRoomsNotifier.pagination();
    }
    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャットスレッド'),
      ),
      body: ref.watchEX(userProvider, complete: (userModel) {
        return Column(
          children: [
            TextButton(
              onPressed: () => createThreadBottomSheet(userId: userModel.id),
              child: const Text('スレを立てる'),
            ),
            Expanded(
              child: ref.watchEX(
                chatRoomsProvider,
                isBackgroundColorNone: ref.watch(chatRoomsProvider).hasError,
                complete: (chatRooms) {
                  // チャットルームイベント

                  return ListView.builder(
                    itemCount: chatRooms.length,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // ルームID追加
                          if (!chatRooms[index].memberUserIds.contains(userModel.id)) {
                            chatRooms[index].memberUserIds.add(userModel.id);
                            ref.read(chatRoomsProvider.notifier).upsertState(chatRooms[index]);
                          }

                          // CHAT画面に遷移
                          context.go('${ChatThreadScreen.metaData['path']}/${ChatScreen.path}',
                              extra: {
                                'label': chatRooms[index].name,
                                'chatRoomId': chatRooms[index].id,
                              });
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(chatRooms[index].name),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
                await chatRoomsNotifier
                    .upsertState(
                  ChatRoomModel.instance(
                    ownerId: userId,
                    name: textController.text,
                    memberUserIds: [userId],
                  ),
                )
                    .whenComplete(() {
                  // なぜかキャッチされないためwhenComplete使用
                  if (!ref.watch(chatRoomsProvider).hasError) {
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
