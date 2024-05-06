import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/features/user/models/user_model.dart';
import 'package:programming_sns/common/utils.dart';

final userAPIProvider = Provider(
  (ref) => UserAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class UserAPI {
  final Databases _db;
  UserAPI({required Databases db}) : _db = db;

  Future<UserModel> get(String id, {bool isCustomError = true}) async {
    return await _db
        .getDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: id,
        )
        .then((doc) => UserModel.fromMap(doc.data))
        .catchError((e) => customErrorMessage(error: e, isCustomError: isCustomError));
  }

  Future<UserModel> create(UserModel userModel, {bool isCustomError = true}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
          data: userModel.toMap(),
        )
        .then((doc) => UserModel.fromMap(doc.data))
        .catchError((e) => customErrorMessage(error: e, isCustomError: isCustomError));
  }

  Future<UserModel> update(UserModel userModel, {bool isCustomError = true}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
          data: userModel.toMap(),
        )
        .then((doc) => UserModel.fromMap(doc.data))
        .catchError((e) => customErrorMessage(error: e, isCustomError: isCustomError));
  }

  Future<List<UserModel>> getList({List<String>? queries, bool isCustomError = true}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          queries: queries,
        )
        .then((docs) => docs.documents.map((doc) => UserModel.fromMap(doc.data)).toList())
        .catchError((e) => customErrorMessage(error: e, isCustomError: isCustomError));
  }

  Future<dynamic> delete(UserModel userModel, {bool isCustomError = true}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
        )
        .catchError((e) => customErrorMessage(error: e, isCustomError: isCustomError));
  }
}
