import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/routes/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

final snackBarProvider = AutoDisposeProvider((ref) {
  final context = ref.read(shellNavigatorKeyProvider).currentState!.context;

  return ({required String message, VoidCallback? onTap}) {
    showTopSnackBar(
      Overlay.of(context),
      SizedBox(
        height: 50,
        child: CustomSnackBar.success(
          message: message,
          backgroundColor: Colors.amber.shade900,
          iconPositionTop: -20,
        ),
      ),
      onTap: onTap,
    );
  };
});

customError({
  dynamic error,
  String? userId,
  String? password,
}) {
  if (error == null) {
    //-------------- 認証系 --------------
    if ((userId?.isEmpty ?? false) || (password?.isEmpty ?? false)) {
      throw '入力は必須だよ(>_<)';
    }

    if (userId != null && !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(userId)) {
      throw 'IDに無効な文字が使われてるよ(>_<)';
    }

    if (password != null && password.length < 8) {
      throw 'パスワードは８桁以上で入れてね(>_<)';
    }
  } else {
    debugPrint(error.toString());

    //-------------- AuthException系 --------------
    if (error is AuthException) {
      final isRegistered = error.message.contains('email address has already been registered');
      if (error.statusCode == '422' && isRegistered) throw 'すでに使われているIDだよ(>_<)';

      final isEmailInvalid = error.message.contains('email address: invalid format');
      if (error.statusCode == '420' && isEmailInvalid) throw 'IDに無効な文字が使われてるよ(>_<)';

      final isLoginInvalid = error.message.contains('Invalid login credentials');
      if (error.statusCode == '400' && isLoginInvalid) throw 'このIDの人は存在しないよ(>_<)';

      final isPasswordSame = error.message.contains('different from the old password');
      if (error.statusCode == '422' && isPasswordSame) throw 'パスワードは前のとは別のにしてね(>_<)';
    }

    if (error is! Exception) throw error;
    throw '''
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ${error.toString()}
      ''';
  }
}

/// catchErrorの拡張版
extension FutureEX<T> on Future<T> {
  /// catchErrorの拡張版
  /// error - エラー
  /// isCustomError デフォルトのエラーか
  Future<T> catchErrorEX({isCustomError = true}) {
    return catchError((e) => isCustomError ? customError(error: e) : throw e);
  }
}

/// catchErrorの拡張版
extension StreamEX<T> on Stream<T> {
  /// catchErrorの拡張版
  /// error - エラー
  /// isCustomError デフォルトのエラーか
  Stream<T> handleErrorEX({isCustomError = true}) {
    return handleError((e) => isCustomError ? customError(error: e) : throw e);
  }
}

Future<String?> uploadImage(String r2Path, {XFile? xFile}) async {
  if (xFile == null) {
    final picker = ImagePicker();
    xFile = await picker.pickImage(source: ImageSource.gallery);
  }

  String? imagePath = xFile?.path;

  if (xFile != null) {
    // MIMEタイプをチェックして画像かどうかを確認
    final String? contentType = xFile.mimeType;
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (contentType == null || !allowedMimeTypes.contains(contentType)) {
      // 画像ファイルでない場合はエラーメッセージを返す
      throw '画像ファイルでお願い(>_<)';
    }

    imagePath = await supabase.functions.invoke(
      "upload-image",
      body: {
        'bucket': 'programming-sns',
        'key': '$r2Path/${DateTime.now()}_${xFile.name}',
        'body': (await xFile.readAsBytes()),
      },
    ).then((res) => res.data['url']);
  }
  return imagePath;
}

/// 画像プレビュー
Future<void> previewImage({required String url, required BuildContext context}) async {
  await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap: () => context.pop(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.1,
              maxScale: 5,
              child: Image.network(url),
            ),
          ],
        ),
      );
    },
  );
}

/// 画像ダウンロード
Future<void> downloadImage(String url) async {
  final Uri parsedUrl = Uri.parse(url);

  if (!await canLaunchUrl(parsedUrl)) throw 'ダウンロードできない(T ^ T)';

  final res = await supabase.functions.invoke("download-image", body: {'url': url});

  final base64 = Uint8List.fromList(List<int>.from(res.data['base64']));

  final fileName = url.split('_')[1];
  final ext = fileName.split('.').last;

  await FileSaver.instance.saveFile(fileName, base64, ext);

  // ref.read(snackBarProvider)(message: '$pathに保存が完了したよ(*^_^*)');
}
