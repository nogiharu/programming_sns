import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/exceptions/exception_message.dart';
import 'package:image_picker/image_picker.dart';

final storageAPIProvider = Provider((ref) {
  return SrorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class SrorageAPI {
  final Storage _storage;
  SrorageAPI({required Storage storage}) : _storage = storage;

  Future<String> uploadImage(XFile xFile, {bool isCatch = true}) async {
    final uint8List = await xFile.readAsBytes().catchError((e) => exceptionMessage(error: e));

    final uploadImage = await _storage
        .createFile(
          bucketId: AppwriteConstants.messageImagesBucket,
          fileId: ID.unique(),
          file: InputFile.fromBytes(bytes: uint8List, filename: xFile.name),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);

    return AppwriteConstants.imageUrl(uploadImage.$id);
  }
}
