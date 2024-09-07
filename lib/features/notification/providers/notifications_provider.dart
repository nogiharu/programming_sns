// ignore_for_file: prefer_function_declarations_over_variables, invalid_return_type_for_catch_error

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/chat/screens/chat_screen.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';
import 'package:programming_sns/features/notification/screens/notification_screen.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  String? firstId;

  /// メンションを特定するために使用
  DateTime? mentionCreatedAt;

  UserModel? get _currentUser => ref.watch(userProvider).value;

  @override
  FutureOr<List<NotificationModel>> build() async {
    firstId ??= await supabase
        .from('notifications')
        .select('id')
        .order('created_at', ascending: true)
        .limit(1)
        .then((v) => v.firstOrNull?['id'])
        .catchErrorEX();

    /// 通知作成イベント
    realtimeEvent();

    return ref.watch(authProvider).maybeWhen(
        data: (auth) async {
          // 初期データ取得
          return await supabase
              .from('notifications')
              .select()
              .eq('user_id', auth.id)
              .order('created_at')
              .limit(25)
              .then(
                (v) => v.map((e) => NotificationModel.fromMap(e)).toList(),
              )
              .catchErrorEX();
        },
        orElse: () => []);
  }

  /// ページネーション
  Future<void> pagination({int limit = 25}) async {
    final data = state.requireValue;
    if (data.isEmpty || data.last.id == firstId) return;

    await asyncGuard<void>(
      () async {
        final result = await supabase
            .from('notifications')
            .select()
            .range(data.length, data.length + limit)
            .order('created_at')
            .limit(limit)
            .then((v) => v.map((e) => NotificationModel.fromMap(e)).toList());

        data.addAll(result);
      },
    );
  }

  /// 更新、作成
  Future<void> upsertState(NotificationModel notification) async {
    await asyncGuard<void>(
      () async {
        debugPrint('upsertだよ');
        await supabase.from('notifications').upsert(notification.toMap());
      },
      isLoading: false,
    );
  }

  /// リアルタイムイベント
  void realtimeEvent() {
    supabase
        .channel('public:notifications')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _currentUser?.id,
            ),
            callback: (payload) {
              update(
                (data) {
                  final newData = NotificationModel.fromMap(payload.newRecord);
                  // 【INSERTイベント】
                  if (PostgresChangeEvent.insert == payload.eventType) {
                    if (newData.userId == _currentUser?.id) {
                      data.insert(0, newData);
                      _createEvent(newData);
                    }
                    debugPrint('【INSERT:通知】');
                  }
                  // 【UPDATEイベント】
                  else if (PostgresChangeEvent.update == payload.eventType) {
                    final index = data.indexWhere((e) => e.id == newData.id);
                    if (index != -1) data[index] = newData;
                    debugPrint('【UPDATE:通知】END');
                  }

                  return data;
                },
              );
            })
        .subscribe();
  }

  /// メンションイベント
  void _createEvent(NotificationModel notification) {
    // どのメッセージがメンションされたか特定するために使用
    // ※ messageIdは作成後にIDが採番されるため
    ref.read(snackBarProvider)(
      message: '${notification.sendByUserName}さんからメンションされました(*^^*)',
      onTap: () {
        final context = ref.read(shellNavigatorKeyProvider).currentContext;
        final chatScreenPath = '${NotificationScreen.metadata['path']}/${ChatScreen.path}';
        // CHAT画面に遷移
        context!.go(chatScreenPath, extra: {
          'label': notification.chatRoomName,
          'chatRoomId': notification.chatRoomId,
        });
        mentionCreatedAt = notification.createdAt;
      },
    );
  }
}
