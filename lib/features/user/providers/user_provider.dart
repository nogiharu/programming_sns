import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> uploadImageWrapper() async {
    final path = await asyncGuard<String?>(() async {
      return await uploadImage('users/${state.value!.id}/');
    });

    if (path != null) {
      await upsertState(state.value!.copyWith(profilePhoto: path));
    }
  }
}
