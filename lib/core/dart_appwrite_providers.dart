import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

final _dartAppwriteClientProvider = Provider((ref) {
  final Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.kEndPoint)
      .setProject(AppwriteConstants.kProjectId)
      .setKey(AppwriteConstants.kApiKey)
      .setLocale('ja');
});

final dartAppwriteUsersProvider = Provider((ref) {
  final client = ref.watch(_dartAppwriteClientProvider);

  return Users(client);
});

// final dartAppwriteAccountProvider = Provider((ref) {
//   final Client client = ref.watch(dartAppwriteClientProvider);
//   return Account(client);
// });
