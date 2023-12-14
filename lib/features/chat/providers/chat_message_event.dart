import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_controller_provider.dart';
import 'package:programming_sns/features/chat/providers/chat_message_provider.dart';
import 'package:programming_sns/features/event/realtime_event_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
final chatMessageEventProvider = AutoDisposeProviderFamily<void, String>((ref, chatRoomId) {
  final stream = ref.watch(realtimeEventProvider2);

  stream.whenOrNull(
    data: (data) {
      final chatController = ref.watch(chatControllerProvider(chatRoomId)).value;
      if (chatController == null) return;
      // final chatMessageUserList = ref.read(chatMessageUserListProvider(chatRoomId)).value;

      // if (chatMessageUserList == null) return;

      final isUserCreateEvent =
          data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.create') &&
              data.payload.containsValue(chatRoomId);

      final isUserUpdateEvent =
          data.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update');
      //  &&  data.payload.containsValue(chatRoomId);

      final isMessageCreateEvent =
          data.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
              data.payload.containsValue(chatRoomId);

      /// ユーザー作成イベント
      if (isUserCreateEvent) {
        debugPrint('USER_CREATE!');
        // ref.read(chatMessageUserListProvider(chatRoomId).notifier).chatUserCreate(data);
      }

      /// メッセージ更新イベント
      if (isUserUpdateEvent) {
        debugPrint('USER_UPDATE!');
        // ref.read(chatMessageUserListProvider(chatRoomId).notifier).chatUserUpdate(data);
      }

      if (isMessageCreateEvent) {
        debugPrint('MESSAGE_CREATE!');
        print('T');
        // ref.read(chatMessageUserListProvider(chatRoomId).notifier).addMessage(data);
        final message = MessageEX.fromMap(data.payload);
        // chatController.addMessage(message);
      }
    },
  );
});
