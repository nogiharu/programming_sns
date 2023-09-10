import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/extensions/message_ex.dart';
import 'package:programming_sns/features/chat/controller/chat_controller.dart';
import 'package:programming_sns/models/user_model.dart';

final appwriteRealtimeMessageProvider = StreamProvider((ref) {
  const messagesDocments =
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollection}.documents';

  const usersDocuments =
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.usersCollection}.documents';

  final stream = ref.read(appwriteRealtimeProvider).subscribe([
    messagesDocments,
    // 'documents',
    usersDocuments,
  ]).stream;

  /// アプリ再起動しないと、キャッシュするため、前のpayloadも保持されてしまう
  stream.listen((event) {
    final isNotClosed =
        !ref.watch(chatControllerProvider.notifier).chatController.messageStreamController.isClosed;
    if (event.events.contains('$messagesDocments.*.create') && isNotClosed) {
      final message = MessageEX.fromMap(event.payload);
      print('TTT');
      // ref.read(chatControllerProvider.notifier).realtimeMessageUpdate(message);
    }
    if (event.events.contains('$usersDocuments.*.update')) {
      final user = UserModel.fromMap(event.payload);
      // ref.read(chatControllerProvider.notifier).realtimeChatUserUpdate(user);
    }
  });

  /// ref.onDispose:プロバイダーが破棄されたときに何が起こるかを指定できる
  // ref.onDispose(() {
  //   // ストリームを閉じる
  //   stream.drain();

  // });

  return stream;
});

final appwriteRealtimeUpdateProvider = Provider((ref) {
  final stream = ref.read(appwriteRealtimeProvider).subscribe([
    AppwriteConstants.messagesDocmentsChannels,
    // 'documents',
    AppwriteConstants.usersDocumentsChannels,
  ]).stream;

  /// アプリ再起動しないと、キャッシュするため、前のpayloadも保持されてしまう
  stream.listen((event) {
    final isNotClosed =
        !ref.watch(chatControllerProvider.notifier).chatController.messageStreamController.isClosed;
    if (event.events.contains('${AppwriteConstants.messagesDocmentsChannels}.*.create') &&
        isNotClosed) {
      final message = MessageEX.fromMap(event.payload);
      ref.read(chatControllerProvider.notifier).realtimeMessageUpdate(message);
    }
    // if (event.events.contains('${AppwriteConstants.usersDocumentsChannels}.*.update')) {
    //   final user = UserModel.fromMap(event.payload);
    //   // ref.read(chatControllerProvider.notifier).realtimeChatUserUpdate(user);
    // }
  });
});
