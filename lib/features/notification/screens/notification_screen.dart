import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:badges/badges.dart' as badges;

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  static Map<String, dynamic> metaData = {
    'path': '/notifier',
    'label': '通知',
    'icon': getIconBadge(),
  };

  static Widget getIconBadge({int notificationCount = 0}) {
    if (notificationCount == 0) {
      return const Icon(Icons.notifications);
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -15),
      badgeStyle: badges.BadgeStyle(
        padding: const EdgeInsets.all(6),
        badgeColor: Colors.amber.shade800,
      ),
      badgeContent: Text(
        '$notificationCount',
        style: const TextStyle(color: Colors.white),
      ),
      child: const Icon(Icons.notifications),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void dispose() {
    super.dispose();

    // ref.read(notificationModelListProvider)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // widget.metaData['icon'] = (widget.metaData['icon'] as badges.Badge).badgeContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: ref.watchEX(
        userModelProvider,
        complete: (userModel) => ref.watchEX(
          notificationListProvider,
          complete: (notificationModelList) {
            // widget.notificationCount = ref.watch(aaa);

            return ListView.builder(
              itemCount: notificationModelList.length,
              itemBuilder: (context, index) {
                final notification = notificationModelList[index];

                return GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: notification.isRead ? null : Colors.amber.shade100,
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: notification.sendByUserName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'さんから${notification.notificationType}されました'),
                        ])),

                        Container(
                          color: Colors.white,
                          child: MarkdownBuilder(message: notification.text),
                        ),
                        // Text(notificationModelList[index].createdAt.toString()),
                        // Text(notificationModelList[index].isRead.toString()),
                      ],
                    ),
                  ),
                  onTap: () {
                    // CHAT画面に遷移
                    context.goNamed(ChatScreen.path, extra: {
                      'label': notificationModelList[index].chatRoomLabel,
                      'chatRoomId': notificationModelList[index].chatRoomId,
                    });
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
