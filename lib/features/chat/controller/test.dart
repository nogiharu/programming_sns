import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/core/providers.dart';
import 'package:appwrite/appwrite.dart';

final appwriteRealtimeMessageProvider = StreamProvider((ref) {
  final stream = ref.watch(appwriteRealtimeProvider).subscribe(['documents']).stream;

  stream.listen((event) {
    print('LISTENだよ');
    print(event.channels);
    if (event.channels.contains(
        'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollection}.documents')) {
      print('payloadだよ');
      print(event.payload);
    }
  });

  return stream;
});

class ReatimeMessageNotifier extends StreamNotifier<RealtimeMessage> {
  @override
  Stream<RealtimeMessage> build() {
    return ref.watch(appwriteRealtimeProvider).subscribe(['documents']).stream;
  }

  void add() {}
}
