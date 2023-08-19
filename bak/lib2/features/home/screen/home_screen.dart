import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  static const String path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final auth = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
      ),
      body: const Center(child: Text('home')),
    );
    // return ref.watchEX(
    //   authNotifierProvider,
    //   complete: (data) {
    //     return Scaffold(
    //         appBar: AppBar(
    //           title: const Text('AppBar'),
    //         ),
    //         body: const Text('Text'));
    //   },
    // );
  }
}
