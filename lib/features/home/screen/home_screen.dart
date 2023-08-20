import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/notifier/auth_notifier.dart';
import 'package:programming_sns/temp/tempScreen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  // static const String path = '/home';
  static const Map<String, dynamic> metaData = {
    'path': '/home',
    'label': 'ホーム',
    'icon': Icon(Icons.home),
    'index': 2,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final auth = ref.watch(authNotifierProvider).value;

    return Scaffold(
        appBar: AppBar(
          title: const Text('AppBar'),
        ),
        body: Center(
            child: Column(
          children: [
            const Text('Text'),
            TextButton(
              onPressed: () {
                context.go(metaData['path'] + '/' + DetailsScreen.path);
              },
              child: const Text('View B details'),
            ),
          ],
        )));

    return ref.watchEX(
      authNotifierProvider,
      complete: (data) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('AppBar'),
            ),
            body: Center(
                child: Column(
              children: [
                const Text('Text'),
                TextButton(
                  onPressed: () {
                    context.go(metaData['path'] + '/' + DetailsScreen.path);
                  },
                  child: const Text('View B details'),
                ),
              ],
            )));
      },
    );
  }
}
