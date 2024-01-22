import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/exceptions/exception_message.dart';

final storageAPIProvider = Provider((ref) {
  return SrorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class SrorageAPI {
  final Storage _storage;
  SrorageAPI({required Storage storage}) : _storage = storage;

  Future<String> uploadImage(MapEntry<String, dynamic> file, {bool isCatch = true}) async {
    final uploadImage = await _storage
        .createFile(
          bucketId: AppwriteConstants.imagesBucket,
          fileId: ID.unique(),
          file: file.value is Uint8List
              ? InputFile.fromBytes(bytes: file.value, filename: file.key)
              : InputFile.fromPath(path: file.value),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);

    return AppwriteConstants.imageUrl(uploadImage.$id);
  }
}
