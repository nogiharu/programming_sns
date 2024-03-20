import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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

  Future<Document> getUserDocument(String id, {bool isDefaultError = false}) async {
    return await _db
        .getDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: id,
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<Document> createUserDocument(UserModel userModel, {bool isDefaultError = false}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
          data: userModel.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<Document> updateUserDocument(UserModel userModel, {bool isDefaultError = false}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
          data: userModel.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<DocumentList> getUsersDocumentList({
    List<String>? queries,
    bool isDefaultError = false,
  }) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          queries: queries,
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<dynamic> deleteUserDocument(UserModel userModel, {bool isDefaultError = false}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.documentId,
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }
}
