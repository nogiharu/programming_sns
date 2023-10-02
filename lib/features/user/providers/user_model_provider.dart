import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:programming_sns/apis/user_api.dart';

import 'package:programming_sns/features/auth/providers/auth_provider.dart';
import 'package:programming_sns/models/user_model.dart';
import 'package:programming_sns/core/dependencies.dart';

final userModelProvider =
    AsyncNotifierProvider<UserModelNotifier, UserModel>(UserModelNotifier.new);

class UserModelNotifier extends AsyncNotifier<UserModel> {
  UserAPI get _userAPI => ref.watch(userAPIProvider);

  @override
  FutureOr<UserModel> build() async {
    return ref.watch(authProvider).maybeWhen(
          data: (user) async {
            final userModel = await _userAPI.getUserDocument(user.$id).then((doc) {
              print('ユーザ取得完了！');
              return UserModel.fromMap(doc.data);
            }).catchError((e) async {
              print('存在しないエラー404');
              // 存在しないエラー404
              if (e is AppwriteException && e.code == 404) {
                final userModel = UserModel.instance(
                  id: user.$id,
                  name: user.$id.substring(15, user.$id.length),
                );
                return await _userAPI.createUserDocument(userModel).then(
                  (doc) {
                    print('ユーザ登録完了！');
                    return UserModel.fromMap(doc.data);
                  },
                );
              }
              throw '$e: USER:やり直してね(；ω；)';
            });
            return userModel;
          },
          orElse: UserModel.instance,
        );
  }

  /// 自分を取る
  // UserModel get currentUser => state.maybeWhen(
  //       orElse: UserModel.instance,
  //       data: (data) => data,
  //     );

  // Future<UserModel> getUserModel(String id) async {
  //   _futureGuard(
  //     () async {
  //       final doc = await _userAPI
  //           .getUserDocument(id)
  //           .catchError((e) => throw ('${e.code}: USER_GET: 出来ない！'));
  //       return UserModel.fromMap(doc.data);
  //     },
  //   );

  //   return state.value!;
  // }

  // Future<UserModel> createUserModel(UserModel userModel) async {
  //   _futureGuard(
  //     () async {
  //       final doc = await _userAPI
  //           .createUserDocument(userModel)
  //           .catchError((e) => throw '${e.code}: USER_CREATE: ユーザ取得できない( ;  ; ）');
  //       return UserModel.fromMap(doc.data);
  //     },
  //   );

  //   return state.value!;
  // }

  Future<UserModel> updateUserModel(UserModel userModel) async {
    _futureGuard(
      () async {
        final doc = await _userAPI
            .updateUserDocument(
              userModel.copyWith(
                updatedAt: DateTime.now(),
              ),
            )
            .catchError((e) => throw ('${e.code}: USER_UPDATE: 出来ない！'));
        return UserModel.fromMap(doc.data);
      },
    );
    return state.value!;
  }

  Future<List<UserModel>> getUserModelList() async {
    final doc = await _userAPI
        .getUsersDocumentList()
        .catchError((e) => throw '${e.code}: USER_LSIT ユーザ取得できない( ;  ; ）');
    final userModelList = doc.documents.map((doc) => UserModel.fromMap(doc.data)).toList();

    return userModelList;
  }

  Future<void> _futureGuard(Future<UserModel> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = await AsyncValue.guard(futureFunction);
    if (state.hasError) {
      Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    }
  }
}
