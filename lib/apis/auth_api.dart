import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/exceptions/exception_message.dart';

final authAPIProvider = Provider(
  (ref) => AuthAPI(
    account: ref.watch(appwriteAccountProvider),
  ),
);

class AuthAPI {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  Future<Session> getSession({bool isCatch = true}) async {
    return await _account
        .getSession(sessionId: 'current')
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
