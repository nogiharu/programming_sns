import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/providers/notifications_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  static Map<String, dynamic> metadata = {
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
  final scrollController = ScrollController();

  late final notificationNotifier = ref.read(notificationsProvider.notifier);

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    super.initState();
  }

  void scrollListener() async {
    // await中にスクロールしたくないため消す
    scrollController.removeListener(scrollListener);
    if (MediaQuery.of(context).size.height < scrollController.position.pixels) {
      await notificationNotifier.pagination();
    }
    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja");

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: ref.watchEX(
        userProvider,
        complete: (userModel) => ref.watchEX(
          notificationsProvider,
          complete: (notifications) {
            return ListView.builder(
              controller: scrollController,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

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
                              text: notification.chatRoomName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'スレッドで'),
                            TextSpan(
                              text: notification.sendByUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'さんから'),
                            TextSpan(
                              text: notification.notificationType.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'されました'),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: MarkdownBuilder(message: notification.message),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    // CHAT画面
                    final chatScreenPath =
                        '${NotificationScreen.metadata['path']}/${ChatScreen.path}';
                    // 遷移
                    context.go(chatScreenPath, extra: {
                      'label': notification.chatRoomName,
                      'chatRoomId': notification.chatRoomId,
                    });
                    // メンション日付を入れる
                    notificationNotifier.mentionCreatedAt = notification.createdAt;
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
