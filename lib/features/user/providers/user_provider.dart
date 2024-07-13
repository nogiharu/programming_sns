import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/common/constans.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/extensions/async_notifier_base_ex.dart';
import 'package:programming_sns/features/auth/providers/auth_provider2.dart';
import 'package:programming_sns/features/user/models/user_model2.dart';

final userProvider = AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() async {
    return ref.watch(authProvider).maybeWhen(
          data: (auth) async {
            // SQL
            return await supabase
                .from('users')
                .select()
                .eq('id', auth.id)
                .then((v) => UserModel.fromMap(v[0]))
                .catchErrorEX();
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
}
