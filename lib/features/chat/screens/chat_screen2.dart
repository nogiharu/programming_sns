import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/theme/theme_color.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class ChatScreen2 extends ConsumerWidget {
  static const String path = 'chatScreen2';

  final String label;
  final String chatRoomId;
  const ChatScreen2({
    super.key,
    required this.label,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: ref.watchEX(
        userModelProvider,
        complete: (userModel) {
          return const Text('text');
        },
      ),
      backgroundColor: ThemeColor.weak,
    );
  }
}
