import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

class ChatRoomScreen extends ConsumerWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watchEX(
      userModelProvider,
      complete: (userModel) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('text'),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              const ListTile();
              return null;
            },
          ),
        );
      },
    );
  }
}
