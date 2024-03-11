import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import '../../../core/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
/// chatControllerのscrollControllerの例外が出るため外だし
final chatMessageEventProvider = AutoDisposeProviderFamily<void, String>((ref, chatRoomId) {
  ref.listen(realtimeEventProvider, (previous, next) {
    next.whenOrNull(
      data: (data) {
        final chatController = ref.watch(chatControllerProvider(chatRoomId)).value;
        if (chatController == null) return;

        /// ユーザー更新イベント
        final isUserUpdateEvent =
            data.events.contains('${AppwriteConstants.kUsersDocumentsChannels}.*.update') &&
                (data.payload['chatRoomIds'] as List<dynamic>).contains(chatRoomId);

        /// メッセージ作成イベント
        final isMessageCreateEvent =
            data.events.contains('${AppwriteConstants.kMessagesDocmentsChannels}.*.create') &&
                data.payload.containsValue(chatRoomId);

        /// メッセージ更新イベント
        final isMessageUpdateEvent =
            data.events.contains('${AppwriteConstants.kMessagesDocmentsChannels}.*.update') &&
                data.payload.containsValue(chatRoomId);

        /// ユーザー更新イベント
        if (isUserUpdateEvent) {
          debugPrint('CHAT_USER_UPDATE!');
          ref.read(chatControllerProvider(chatRoomId).notifier).updateChatUserEvent(data);
        }

        /// メッセージ作成イベント
        if (isMessageCreateEvent) {
          debugPrint('MESSAGE_CREATE!');
          final message = MessageEX.fromMap(data.payload);
          chatController.addMessage(message);
          message.message;
        }

        /// メッセージ更新イベント
        if (isMessageUpdateEvent) {
          debugPrint('MESSAGE_UPDATE!');
          ref.read(chatControllerProvider(chatRoomId).notifier).updateMessageEvent(data);
        }
      },
    );
  });
});
