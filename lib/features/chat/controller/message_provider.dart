import 'dart:async';

import 'package:programming_sns/apis/message_api.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/extensions/message_ex.dart';

class MessageNotifier extends AsyncNotifier<List<Message>> {
  @override
  FutureOr<List<Message>> build() async {
    final messageList = await ref.watch(messageAPIProvider).getMessagesDocumentList().then(
          (docList) => docList.documents
              .map(
                (doc) => MessageEX.fromMap(doc.data),
              )
              .toList(),
        );
    return messageList;
  }
}
