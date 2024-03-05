import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/providers/chat_room_provider.dart';
import '../../../core/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
final chatRoomEventProvider = AutoDisposeProvider<void>((ref) {
  ref.listen(realtimeEventProvider, (previous, next) {
    next.whenOrNull(
      data: (data) {
        final isChatRoomCreateEvent =
            data.events.contains('${AppwriteConstants.chatRoomDocmentsChannels}.*.create');
        final isChatRoomUpdateEvent =
            data.events.contains('${AppwriteConstants.chatRoomDocmentsChannels}.*.update');

        /// チャットルーム作成イベント
        if (isChatRoomUpdateEvent) {
          debugPrint('CHAT_ROOM_UPDATE!');
          ref.read(chatRoomProvider.notifier).updateChatRoomEvent(data);
        }

        /// チャットルーム作成イベント
        if (isChatRoomCreateEvent) {
          debugPrint('CHAT_ROOM_CREATE!');
          ref.read(chatRoomProvider.notifier).createChatRoomEvent(data);
        }
      },
    );
  });
});
