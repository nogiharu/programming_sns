import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_room_model_list_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/providers/notification_model_list_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});
  static const Map<String, dynamic> metaData = {
    'path': '/notifier',
    'label': '通知',
    'icon': Icon(Icons.notifications),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: ref.watchEX(
        userModelProvider,
        complete: (userModel) => ref.watchEX(
          notificationModelListProvider,
          complete: (notificationModelList) {
            return ListView.builder(
              itemCount: notificationModelList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Container(
                    color: Colors.lightBlueAccent,
                    child: Column(
                      children: [
                        Text(notificationModelList[index].text),
                        Text(notificationModelList[index].isRead.toString()),
                        Text(notificationModelList[index].notificationType.toString()),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                  onTap: () async {
                    final messageId = notificationModelList[index].messageId;
                    final chatRoomId = notificationModelList[index].chatRoomId;
                    final queries = [
                      Query.equal('chatRoomId', chatRoomId),
                      Query.limit(100000),
                      Query.greaterThanEqual('\$id', messageId!),
                    ];
                    final messages = (await ref
                            .read(messageAPIProvider)
                            .getMessageDocumentList(queries: queries))
                        .documents
                        .map((e) => MessageEX.fromMap(e.data))
                        .toList();

                    messages.forEach((element) {
                      print('createdAt:${element.createdAt} message:${element.message}');
                    });

                    if (context.mounted) {
                      // CHAT画面に遷移
                      context.goNamed(ChatScreen.path, extra: {
                        'label': 'aaa',
                        'chatRoomId': notificationModelList[index].chatRoomId,
                      });
                      if (ref.read(chatControllerProvider(chatRoomId!)).value != null) {
                        ref.read(chatControllerProvider(chatRoomId)).value!.initialMessageList =
                            messages;
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
