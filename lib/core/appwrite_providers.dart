import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';

final _appwriteClientProvider = Provider((ref) {
  final Client client = Client();

  return client
      .setEndpoint(AppwriteConstants.kEndPoint)
      .setProject(AppwriteConstants.kProjectId)
      .setLocale('ja')
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref) {
  final Client client = ref.watch(_appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final Client client = ref.watch(_appwriteClientProvider);
  return Databases(client);
});

final appwriteRealtimeProvider = Provider((ref) {
  final Client client = ref.watch(_appwriteClientProvider);
  return Realtime(client);
});

final appwriteStorageProvider = Provider((ref) {
  final Client client = ref.watch(_appwriteClientProvider);
  return Storage(client);
});
