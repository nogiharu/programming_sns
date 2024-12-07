import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:programming_sns/features/chat/providers/chat_rooms_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:programming_sns/theme/theme_color.dart';
import 'package:programming_sns/widgets/input_field.dart';

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('チャットスレッド'),
      ),
      body: ref.watchEX(userProvider, complete: (userModel) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputField(
                labelText: 'スレッドを立てる',
                controller: textController,
                hintText: 'スレッド名は5文字以上で入れてね(^^)',
                contentPadding: 20,
                isMaxLines: true,
                isLabelAnimation: true,
                borderColor: ThemeColor.main,
                suffixIcon: IconButton(
                  onPressed: () async {
                    await onSend(userModel.id);
                  },
                  icon: const Icon(
                    Icons.send,
                    color: ThemeColor.main,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ref.watchEX(
                chatRoomsProvider,
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

  Future<void> onSend(String userId) async {
    await chatRoomsNotifier.upsertState(ChatRoomModel.instance(
      ownerId: userId,
      name: textController.text,
      memberUserIds: [userId],
    ));

    if (!ref.watch(chatRoomsProvider).hasError) {
      textController.text = '';
      ref.read(snackBarProvider)(message: '作成完了だよ(*^_^*)');
    }
  }
}
