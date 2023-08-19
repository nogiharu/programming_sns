import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class test extends ConsumerWidget {
  const test({super.key});
  static const String path = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Container(
      color: Colors.amberAccent,
      child: const Center(
        child: Text(
          'タイトル', // 中央に "HSP" と表示
          style: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }
}

// abstract class BaseScreen extends ConsumerWidget {
//   static Map<String, dynamic> metaData(
//       {required String path, required String label, required Icon icon}) {
//     return {'path': path, 'label': label, 'icon': icon};
//   }

//   const BaseScreen({super.key});
// }

class ScreenA extends ConsumerWidget {
  const ScreenA({super.key});
  static const String path = '/a';

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
                context.go('${ScreenA.path}/${DetailsScreen.path}');
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
  static const String path = '/b';
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
