import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/providers/chat_message_list_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_user_list.dart';
import 'package:programming_sns/features/event/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
/// chatControllerのscrollControllerの例外が出るため外だし
final chatMessageEventProvider = AutoDisposeProviderFamily<void, String>((ref, chatRoomId) {
  ref.listen(realtimeEventProvider, (previous, next) {
    next.whenOrNull(
      data: (data) {
        final isUserCreateEvent =
            data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create') &&
                data.payload.containsValue(chatRoomId);

        final isUserUpdateEvent =
            data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update') &&
                data.payload.containsValue(chatRoomId);

        final isMessageCreateEvent =
            data.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
                data.payload.containsValue(chatRoomId);

        /// ユーザー作成イベント
        if (isUserCreateEvent) {
          debugPrint('USER_CREATE!');
          ref.read(chatUserListProvider(chatRoomId).notifier).chatUserCreate(data);
        }

        /// ユーザー更新イベント
        if (isUserUpdateEvent) {
          debugPrint('USER_UPDATE!');
          ref.read(chatUserListProvider(chatRoomId).notifier).chatUserUpdate(data);
        }

        /// メッセージ作成イベント
        if (isMessageCreateEvent) {
          debugPrint('MESSAGE_CREATE!');
          ref.read(chatMessageListProvider(chatRoomId).notifier).addMessage(data);
        }
      },
    );
  });
});
