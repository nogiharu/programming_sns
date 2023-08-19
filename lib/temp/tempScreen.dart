import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScreenA extends ConsumerWidget {
  const ScreenA({super.key});
  // static const String path = '/a';
  static const Map<String, dynamic> metaData = {
    'path': '/a',
    'label': 'スクリーンA',
    'icon': Icon(Icons.person),
    'index': 0,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('text'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Screen A'),
            TextButton(
              onPressed: () {
                // context.go('/a/details');
                context.go('${ScreenA.metaData['path']}/${DetailsScreen.path}');
                // context.go('${ScreenA.id}/${DetailsScreen.id}');
                // GoRouter.of(context).go('/a/details');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenB extends ConsumerWidget {
  const ScreenB({super.key});
  // static const String path = '/b';
  static const Map<String, dynamic> metaData = {
    'path': '/b',
    'label': 'スクリーンB',
    'icon': Icon(Icons.business),
    'index': 1,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                //  await userService.signIn();
                //  context.go(ScreenB.id);
              },
              child: const Text('ログイン'),
            ),
            const Text('Screen B'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/b/details');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({
    required this.label,
    super.key,
  });
  static const String path = 'details';
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watchEX(
    //   authNotifierProvider,
    //   complete: (a) {
    //     return const Text('text');
    //   },
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Text(
          'Details for $label',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
