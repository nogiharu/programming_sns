import 'package:appwrite/appwrite.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/utils/exception_message.dart';
import 'package:image_picker/image_picker.dart';

final storageAPIProvider = Provider((ref) {
  return SrorageAPI(storage: ref.watch(appwriteStorageProvider));
});

/// 画像アップロード
class SrorageAPI {
  final Storage _storage;
  SrorageAPI({required Storage storage}) : _storage = storage;

  Future<String> uploadImage(XFile xFile, String bucketId, {bool isCatch = true}) async {
    final uint8List = await xFile.readAsBytes().catchError((e) => exceptionMessage(error: e));

    return await _storage
        .createFile(
          bucketId: bucketId,
          fileId: ID.unique(),
          file: InputFile.fromBytes(bytes: uint8List, filename: xFile.name),
        )
        .then((uploadImage) => AppwriteConstants.imageUrl(uploadImage.$id))
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// 画像ダウンロード
  Future<bool> downloadImage(String url, String bucketId, {bool isCatch = true}) async {
    RegExp regex = RegExp(r'/files/([a-zA-Z0-9]+)');
    String? imageId = regex.firstMatch(url)?.group(1);
    if (imageId == null) return false;

    return await _storage
        .getFileDownload(
      bucketId: bucketId,
      fileId: imageId,
    )
        .then((uint8List) async {
      // ファイル情報取得
      final file = await _storage.getFile(bucketId: bucketId, fileId: imageId);
      // 保存
      bool isSave = false;
      if (kIsWeb) {
        isSave = (await FileSaver.instance.saveFile(file.name, uint8List, file.name.split('.')[1]))
            .isNotEmpty;
      } else {
        isSave = (await ImageGallerySaver.saveImage(uint8List))['isSuccess'] as bool;
      }
      return isSave;
    }).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// 画像プレビュー
  Future<Uint8List> previewImgae(String url, String bucketId, {bool isCatch = true}) async {
    RegExp regex = RegExp(r'/files/([a-zA-Z0-9]+)');
    String? imageId = regex.firstMatch(url)?.group(1);

    return await _storage
        .getFilePreview(bucketId: bucketId, fileId: imageId!)
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
