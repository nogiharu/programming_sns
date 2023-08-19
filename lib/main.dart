import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:programming_sns/common/loading.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/routes/router.dart';

late Box box;
Future<void> main() async {
  await Hive.initFlutter();
  box = await Hive.openBox('users');
  runApp(const ProviderScope(
    child: Main(),
  ));
}

class Main extends ConsumerWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      builder: (context, child) => Loading(
        child: child,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(
        router,
      ),
      scaffoldMessengerKey: ref.read(scaffoldMessengerKeyProvider),
    );
  }
}
