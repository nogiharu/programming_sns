import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/extensions/widget_ref_ex.dart';
import 'package:programming_sns/features/chat/providers/chat_historys_provider.dart';
import 'package:programming_sns/features/user/providers/user_provider.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  static const Map<String, dynamic> metadata = {
    'path': '/chatHistory',
    'label': '履歴',
    'icon': Icon(Icons.chat),
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('チャット履歴'),
        ),
        body: ref.watchEX(
          userProvider,
          complete: (user) => ref.watchEX(
            chatHistorysProvider,
            complete: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  print(data[index].chatRoomId);
                  return GestureDetector(
                      child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].message),
                      ],
                    ),
                  ));
                },
              );
            },
          ),
        ));
  }
}
