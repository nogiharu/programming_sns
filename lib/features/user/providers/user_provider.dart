import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:programming_sns/core/constans.dart';
import 'package:programming_sns/core/utils.dart';
import 'package:programming_sns/core/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final userProvider = AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() async {
    return ref.watch(authProvider).maybeWhen(
          data: (auth) async {
            // TODO StreamNotifierにしてリアルタイムに返してupsertStateをvoidにするか検討必要
            return await getUserModel(auth.id);
          },
          orElse: () => UserModel.instance(),
        );
  }

  /// ユーザー更新
  Future<UserModel> upsertState(UserModel userModel) async {
    return await asyncGuard(
      () async {
        // SQL
        return await supabase
            .from('users')
            .upsert(userModel.toMap())
            .select()
            .then((v) => UserModel.fromMap(v[0]));
      },
    );
  }

  /// ユーザー更新
  Future<UserModel> getUserModel(String id) async {
    // SQL
    return await supabase
        .from('users')
        .select()
        .eq('id', id)
        .then((v) => UserModel.fromMap(v[0]))
        .catchErrorEX();
  }

  Future<void> uploadImage() async {
    final path = await asyncGuard<String?>(() async {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery);
      String? imagePath = xFile?.path;
      if (xFile != null) {
        // MIMEタイプをチェックして画像かどうかを確認
        final String? contentType = xFile.mimeType;
        const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
        if (contentType == null || !allowedMimeTypes.contains(contentType)) {
          // 画像ファイルでない場合はエラーメッセージを返す
          throw '画像ファイルでお願い(>_<)';
        }

        imagePath = await supabase.functions
            .invoke(
              "upload-image",
              body: {
                'bucket': 'programming-sns',
                'key': 'profiles/${state.value!.id}/${DateTime.now()}_${xFile.name}',
                'body': (await xFile.readAsBytes()),
              },
            )
            .then((res) => res.data['url'])
            .catchErrorEX();
      }
      return imagePath;
    });

    await upsertState(state.value!.copyWith(profilePhoto: path));
  }
}
