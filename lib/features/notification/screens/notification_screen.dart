import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/profile/providers/user_model_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});
  static const Map<String, dynamic> metaData = {
    'path': '/notifier',
    'label': '通知',
    'icon': Icon(Icons.notifications),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: ref.watchEX(
        userModelProvider,
        complete: (data) {
          return const Text('text');
        },
      ),
    );
  }
}
