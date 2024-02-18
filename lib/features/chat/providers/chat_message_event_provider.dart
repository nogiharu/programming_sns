import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import '../../../events/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
/// chatControllerのscrollControllerの例外が出るため外だし
final chatMessageEventProvider = AutoDisposeProviderFamily<void, String>((ref, chatRoomId) {
  ref.listen(realtimeEventProvider, (previous, next) {
    next.whenOrNull(
      data: (data) {
        final chatController = ref.watch(chatControllerProvider(chatRoomId)).value;
        if (chatController == null) return;

        final isUserCreateEvent =
            data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create') &&
                data.payload.containsValue(chatRoomId);

        final isUserUpdateEvent =
            data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update') &&
                data.payload.containsValue(chatRoomId);

        final isMessageCreateEvent =
            data.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
                data.payload.containsValue(chatRoomId);

        final isMessageUpdateEvent =
            data.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.update') &&
                data.payload.containsValue(chatRoomId);

        /// ユーザー作成イベント
        if (isUserCreateEvent) {
          debugPrint('USER_CREATE!');
          ref.read(chatControllerProvider(chatRoomId).notifier).createChatUser(data);
        }

        /// ユーザー更新イベント
        if (isUserUpdateEvent) {
          debugPrint('USER_UPDATE!');
          ref.read(chatControllerProvider(chatRoomId).notifier).updateChatUser(data);
        }

        /// メッセージ作成イベント
        if (isMessageCreateEvent) {
          debugPrint('MESSAGE_CREATE!');
          final message = MessageEX.fromMap(data.payload);
          chatController.addMessage(message);
        }

        /// メッセージ更新イベント
        if (isMessageUpdateEvent) {
          debugPrint('MESSAGE_UPDATE!');
          ref.read(chatControllerProvider(chatRoomId).notifier).updateMessage(data);
        }
      },
    );
  });
});