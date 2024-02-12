import 'package:appwrite/appwrite.dart';

exceptionMessage({dynamic error, String? loginId, String? loginPassword}) {
  //-------------- 認証系 --------------
  if ((loginId?.isEmpty ?? false) || (loginPassword?.isEmpty ?? false)) {
    throw '入力は必須だよ(>_<)';
  }

  if (loginId != null && !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(loginId)) {
    throw 'IDに無効な文字が使われてるよ(>_<)';
  }

  if (loginPassword != null && loginPassword.length < 8) {
    throw 'パスワードは８桁以上で入れてね(>_<)';
  }

  //-------------- API系 --------------
  if (error != null) {
    if (error is AppwriteException && error.code == 409) {
      throw '既に使われているIDだよ(>_<)';
    }
    throw '''
      code：${error is AppwriteException ? '${error.code}' : ''}
      予期せぬエラーだあ(T ^ T)
      再立ち上げしてね(>_<)
      ''';
  }
}
