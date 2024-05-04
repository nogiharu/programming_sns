import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/features/notification/providers/notification_list_provider.dart';
import '../../../core/realtime_event_provider.dart';

/// ホットリロードしたら例外が出るため、再立ち上げする
/// buildメソッドの中に直書きしたら、何故か重複でイベントが出るため、外だし
final notificationEventProvider = AutoDisposeProvider<void>((ref) {
  ref.listen(realtimeEventProvider, (_, next) {
    next.whenOrNull(
      data: (data) {
        final isNotificationCreateEvent =
            data.events.contains('${AppwriteConstants.kNotificationDocmentsChannels}.*.create');

        /// 通知作成イベント
        if (isNotificationCreateEvent) {
          debugPrint('NOTIFICATION_CREATE!');
          ref.read(notificationListProvider.notifier).onUpdateState(data);
        }
      },
    );
  });
});
