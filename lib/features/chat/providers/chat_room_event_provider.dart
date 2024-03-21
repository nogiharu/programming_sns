import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/providers/chat_room_model_list_provider.dart';
import '../../../core/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
/// FIXME ここがログを出している！
final chatRoomEventProvider = AutoDisposeProvider<void>((ref) {
  ref.listen(realtimeEventProvider, (previous, next) {
    next.whenOrNull(
      data: (data) {
        final isChatRoomCreateEvent =
            data.events.contains('${AppwriteConstants.kChatRoomDocmentsChannels}.*.create');
        final isChatRoomUpdateEvent =
            data.events.contains('${AppwriteConstants.kChatRoomDocmentsChannels}.*.update');

        /// チャットルーム作成イベント
        if (isChatRoomUpdateEvent) {
          debugPrint('CHAT_ROOM_UPDATE!');
          ref.read(chatRoomModelListProvider.notifier).updateChatRoomEvent(data);
        }

        /// チャットルーム作成イベント
        if (isChatRoomCreateEvent) {
          debugPrint('CHAT_ROOM_CREATE!');
          ref.read(chatRoomModelListProvider.notifier).createChatRoomEvent(data);
        }
      },
    );
  });
});
