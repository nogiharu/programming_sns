import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';

final realtimeEventProvider = Provider((ref) {
  final stream = ref.watch(appwriteRealtimeProvider).subscribe([
    AppwriteConstants.chatRoomDocmentsChannels,
    AppwriteConstants.messagesDocmentsChannels,
    AppwriteConstants.usersDocumentsChannels,
  ]).stream;

  return stream;
});
