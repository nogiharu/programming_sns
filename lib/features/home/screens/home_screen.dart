import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/controller/chat_controller.dart';
import 'package:programming_sns/features/chat/controller/chat_controller2.dart';
import 'package:programming_sns/features/user/providers/user_model_provider.dart';
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

    // return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('AppBar'),
    //     ),
    //     body: Center(
    //         child: Column(
    //       children: [
    //         const Text('Text'),
    //         TextButton(
    //           onPressed: () {
    //             context.go(metaData['path'] + '/' + DetailsScreen.path);
    //           },
    //           child: const Text('View B details'),
    //         ),
    //       ],
    //     )));
    // userModelProvider.notifier;
    return ref.watchEX(
      userModelProvider,
      // userModelProvider.notifier,
      complete: (data) {
        // print(data.name);
        return Scaffold(
          appBar: AppBar(
            title: const Text('AppBar'),
          ),
          body: Center(
            child: Column(
              children: [
                Text(data.id),
                TextButton(
                  onPressed: () {
                    context.go(metaData['path'] + '/' + DetailsScreen.path);
                  },
                  child: Text(data.name),
                ),
                TextButton(
                  onPressed: () async {
                    String name;
                    if (data.name == '田島') {
                      name = '山田';
                    } else if (data.name == '山田') {
                      name = 'チコリータ';
                    } else {
                      name = '田島';
                    }

                    data = data.copyWith(name: name);
                    final aa = await ref.read(userModelProvider.notifier).updateUserModel(data);
                    final aaa = await ref.read(userModelProvider.notifier).getUserModelList();
                    // print(aaa);
                  },
                  child: const Text('名前変更'),
                ),
                TextButton(
                  onPressed: () async {
                    final messageList = await ref
                        .watch(messageAPIProvider)
                        .getMessagesDocumentList()
                        .then((docList) =>
                            docList.documents.map((doc) => MessageEX.fromMap(doc.data)).toList());

                    await Future.forEach(messageList, (e) async {
                      print(e.id);
                      ref.read(messageAPIProvider).deleteMessageDocument(e.id);
                    });
                  },
                  child: const Text('メッセージ全消し'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
