import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';

// final realtimeEventProvider = AutoDisposeProvider((ref) {
//   final stream = ref.watch(appwriteRealtimeProvider).subscribe([
//     AppwriteConstants.chatRoomDocmentsChannels,
//     AppwriteConstants.messagesDocmentsChannels,
//     AppwriteConstants.usersDocumentsChannels,
//   ]).stream;

//   return stream;
// });

final realtimeEventProvider2 = AutoDisposeStreamProvider((ref) async* {
  final stream = ref.watch(appwriteRealtimeProvider).subscribe([
    AppwriteConstants.chatRoomDocmentsChannels,
    AppwriteConstants.messagesDocmentsChannels,
    AppwriteConstants.usersDocumentsChannels,
  ]).stream;

  await for (final e in stream) {
    yield e;
  }
});
