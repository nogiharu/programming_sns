import 'package:appwrite/appwrite.dart';

String authExceptionMessage({dynamic error, String? loginId, String? loginPassword}) {
  RegExp regExp = RegExp(r'^[a-zA-Z0-9._]+$');
  // ID
  if (loginId != null && loginPassword != null) {
    // 空
    if (loginId == '' || loginPassword == '') {
      return '入力は必須だよ(>_<)';
    }
    // 無効
    else if (!regExp.hasMatch(loginId)) {
      return 'IDに無効な文字が使われてるよ(>_<)';
    }
    // パスワード
    else if (loginPassword.length < 7) {
      return 'パスワードは８桁以上で入れてね(>_<)';
    }
  }

  // APIエラー
  if (error != null) {
    if (error is AppwriteException && error.code == 409) {
      return '既に使われているIDだよ(>_<)';
    } else {
      return '''
    予期せぬエラーだあ(T ^ T)
    再立ち上げしてね(>_<)
    ''';
    }
  }
  return '';
}
