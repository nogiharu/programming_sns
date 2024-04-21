import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/markdown/markdown_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/message_api_provider.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
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
                              text: notification.chatRoomLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'スレッドで',
                            ),
                            TextSpan(
                              text: notification.sendByUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'さんから',
                            ),
                            TextSpan(
                              text: notification.notificationType.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'されました',
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
                  onTap: () async {
                    // どのメッセージがメンションされたか特定するために使用
                    // ※ messageIdは作成後にIDが採番されるため
                    final queries = [
                      Query.equal('message', notification.text),
                      Query.equal('updatedAt', notification.createdAt.millisecondsSinceEpoch),
                    ];
                    await ref
                        .read(messageAPIProvider)
                        .getMessageDocumentList(queries: queries)
                        .then((e) {
                      if (e.documents.isEmpty) return;

                      final message = MessageEX.fromMap(e.documents.first.data);
                      ref.read(mentionMessageIdProvider.notifier).state = message.id;

                      // CHAT画面に遷移
                      ref
                          .read(notificationListProvider.notifier)
                          .navigateToChatScreen(notification: notification);
                    });

                    // // CHAT画面に遷移
                    // if (mounted) {
                    //   context.goNamed(ChatScreen.path, extra: {
                    //     'label': notification.chatRoomLabel,
                    //     'chatRoomId': notification.chatRoomId,
                    //   });

                    //   // 既読していないなら既読する awaitはしない
                    //   if (!notification.isRead) {
                    //     ref.read(notificationListProvider.notifier).updateNotification(
                    //           notificationModel: notification.copyWith(isRead: true),
                    //         );
                    //   }
                    // }
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
