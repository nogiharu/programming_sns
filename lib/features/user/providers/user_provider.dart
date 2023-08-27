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
    final user = ref.watch(authProvider).value!;

    final userModel = await _userAPI.getUserDocument(user.$id).then((doc) {
      print('ユーザ取得完了！');
      return UserModel.fromMap(doc.data);
    }).catchError((e) async {
      print('存在しないエラー404');
      // 存在しないエラー404
      if (e is AppwriteException && e.code == 404) {
        final userModel = UserModel(
          id: user.$id,
          name: user.$id.substring(15, user.$id.length),
          profilePhoto: '',
        );
        return await _userAPI.createUserDocument(userModel).then(
          (doc) {
            print('ユーザ登録完了！');
            return UserModel.fromMap(doc.data);
          },
        );
      }
      throw '${e.code}: USER:やり直してね(；ω；)';
    });

    return userModel;
  }

  Future<UserModel> getUserModel(String id) async {
    _futureGuard(
      () async {
        final doc = await _userAPI
            .getUserDocument(id)
            .catchError((e) => throw ('${e.code}: USER_GET: 出来ない！'));
        return UserModel.fromMap(doc.data);
      },
    );

    // final prevState = state.copyWithPrevious(state);
    // state = await AsyncValue.guard(
    //   () async {
    //     final doc = await _userAPI
    //         .getUserDocument(id)
    //         .catchError((e) => throw ('${e.code}: USER_GET: 出来ない！'));
    //     return UserModel.fromMap(doc.data);
    //   },
    // );
    // if (state.hasError) {
    //   Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    // }
    return state.value!;
  }

  Future<UserModel> createUserModel(UserModel userModel) async {
    _futureGuard(
      () async {
        final doc = await _userAPI
            .createUserDocument(userModel)
            .catchError((e) => throw '${e.code}: USER_CREATE: ユーザ取得できない( ;  ; ）');
        return UserModel.fromMap(doc.data);
      },
    );
    // final prevState = state.copyWithPrevious(state);
    // state = await AsyncValue.guard(
    //   () async {
    //     final doc = await _userAPI
    //         .createUserDocument(userModel)
    //         .catchError((e) => throw '${e.code}: USER_CREATE: ユーザ取得できない( ;  ; ）');
    //     return UserModel.fromMap(doc.data);
    //   },
    // );
    // if (state.hasError) {
    //   Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    // }
    return state.value!;
  }

  Future<void> updateUser(UserModel userModel) async {
    _futureGuard(
      () async {
        final doc = await _userAPI
            .updateUserDocument(userModel)
            .catchError((e) => throw ('${e.code}: USER_UPDATE: 出来ない！'));
        return UserModel.fromMap(doc.data);
      },
    );
    // final prevState = state.copyWithPrevious(state);
    // state = await AsyncValue.guard(
    //   () async {
    //     final doc = await _userAPI
    //         .updateUserDocument(userModel)
    //         .catchError((e) => throw ('${e.code}: USER_UPDATE: 出来ない！'));
    //     return UserModel.fromMap(doc.data);
    //   },
    // );
    // if (state.hasError) {
    //   Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    // }
  }

  Future<void> _futureGuard(Future<UserModel> Function() futureFunction) async {
    final prevState = state.copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      return await futureFunction.call();
    });
    if (state.hasError) {
      Future.delayed(const Duration(milliseconds: 1000), () => state = prevState);
    }
  }
}
