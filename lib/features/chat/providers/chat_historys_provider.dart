import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

final chatHistorysProvider =
    AsyncNotifierProvider<ChatHistorysNotifier, List<Message>>(ChatHistorysNotifier.new);

class ChatHistorysNotifier extends AsyncNotifier<List<Message>> {
  @override
  FutureOr<List<Message>> build() async {
    final userId = ref.watch(userProvider).value?.id;

    final response = await supabase.rpc(
      'send_user_messages',
      params: {'user_id': userId},
    ).then((res) {
      return (res as List<dynamic>).map((v) => MessageEX.fromMap(v)).toList();
    });

    return response;
  }
}
