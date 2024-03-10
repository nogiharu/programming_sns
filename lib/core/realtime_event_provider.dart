import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';

/// 前回の値が保持されてしまうためyieldする
final realtimeEventProvider = AutoDisposeStreamProvider((ref) async* {
  final stream = ref.watch(appwriteRealtimeProvider).subscribe([
    AppwriteConstants.kChatRoomDocmentsChannels,
    AppwriteConstants.kMessagesDocmentsChannels,
    AppwriteConstants.kUsersDocumentsChannels,
  ]).stream;

  await for (final e in stream) {
    yield e;
  }
});
