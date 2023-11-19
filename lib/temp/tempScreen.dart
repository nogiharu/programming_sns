import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';

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

class ScreenB extends ConsumerStatefulWidget {
  const ScreenB({super.key});
  static const Map<String, dynamic> metaData = {
    'path': '/b',
    'label': 'スクリーンB',
    'icon': Icon(Icons.business),
    'index': 1,
  };
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenRefreshState();
}

class _ScreenRefreshState extends ConsumerState<ScreenB> {
  @override
  Widget build(BuildContext context) {
    final a = [
      Container(
        color: Colors.amber,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.black,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        // width: 100,
        height: 100,
      ),
    ];
    return Scaffold(
        appBar: AppBar(title: const Text('text')),
        body: ref.watchEX(
          userModelProvider,
          complete: (p0) {
            return RefreshIndicator(
              onRefresh: () async {
                // setState(() {});
                return await Future.delayed(
                  const Duration(seconds: 3),
                );
              },
              child: ListView.builder(
                itemCount: a.length,
                itemBuilder: (context, index) {
                  return a[index];
                },
              ),
            );
          },
        ));
    return Container();
  }
}

class ScreenM extends ConsumerWidget {
  const ScreenM({super.key});
  // static const String path = '/b';
  static const Map<String, dynamic> metaData = {
    'path': '/b',
    'label': 'スクリーンB',
    'icon': Icon(Icons.business),
    'index': 1,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = [
      Container(
        color: Colors.amber,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.black,
        // width: 100,
        height: 100,
      ),
      Container(
        color: Colors.blue,
        // width: 100,
        height: 100,
      ),
    ];
    return RefreshIndicator(
        onRefresh: () async {
          return Future.delayed(
            const Duration(seconds: 3),
          );
        },
        child: ref.watchEX(
          userModelProvider,
          complete: (p0) {
            return ListView.builder(
              itemCount: a.length,
              itemBuilder: (context, index) {
                return a[index];
              },
            );
          },
        ));

    return ref.watchEX(
      authProvider,
      complete: (_) {
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
      },
    );
  }
}

class ScreenC extends ConsumerWidget {
  const ScreenC({super.key});
  // static const String path = '/b';
  static const Map<String, dynamic> metaData = {
    'path': '/c',
    'label': 'スクリーンC',
    'icon': Icon(Icons.chat),
    'index': 3,
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
            const Text('Screen C'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Details for $label',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/a/details/details2');
              },
              child: const Text('View B details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen2 extends ConsumerWidget {
  const DetailsScreen2({
    required this.label,
    super.key,
  });
  static const String path = 'details2';
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen2'),
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
