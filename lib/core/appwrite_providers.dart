import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';

final appwriteClientProvider = Provider((ref) {
  final Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.kEndPoint)
      .setProject(AppwriteConstants.kProjectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref) {
  final Client client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final Client client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteRealtimeProvider = Provider((ref) {
  final Client client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});

final appwriteStorageProvider = Provider((ref) {
  final Client client = ref.watch(appwriteClientProvider);
  return Storage(client);
});
