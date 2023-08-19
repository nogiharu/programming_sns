import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib2/constants/appwrite_constants.dart';

final appwriteClientProvider = Provider((ref) {
  final Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
});

final appwriteAccountProvider = Provider((ref) {
  final Client client = ref.watch(appwriteClientProvider);
  return Account(client);
});
