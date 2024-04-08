import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/providers/notification_event_provider.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: ref.watchEX(
        userModelProvider,
        complete: (userModel) => ref.watchEX(
          notificationListProvider,
          complete: (notificationModelList) {
            return ListView.builder(
              itemCount: notificationModelList.length,
              itemBuilder: (context, index) {
                final notification = notificationModelList[index];

                return GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: notification.isRead ? null : Colors.amber.shade100,
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                                  '${DateFormat.MMMd('ja').format(notification.createdAt)}${DateFormat.Hm('ja').format(notification.createdAt)} ',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            TextSpan(
                              text: notification.sendByUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: 'さんから${notification.notificationType}されました',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: MarkdownBuilder(message: notification.text),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    // CHAT画面に遷移
                    context.goNamed(ChatScreen.path, extra: {
                      'label': notificationModelList[index].chatRoomLabel,
                      'chatRoomId': notificationModelList[index].chatRoomId,
                    });
                    // 既読していないなら既読する
                    if (!notificationModelList[index].isRead) {
                      ref.read(notificationListProvider.notifier).updateNotification(
                            notificationModel: notificationModelList[index].copyWith(isRead: true),
                          );
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
