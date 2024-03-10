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

  Future<Document> getUserDocument(String id, {bool isCatch = true}) async {
    return await _db
        .getDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: id,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> createUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.id,
          data: userModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> updateUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.id,
          data: userModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<DocumentList> getUsersDocumentList({String? chatRoomId, bool isCatch = true}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          queries: chatRoomId == null
              ? [Query.limit(100000)]
              : [
                  Query.search('chatRoomIds', chatRoomId),
                  Query.limit(100000),
                ],
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> deleteUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kUsersCollection,
          documentId: userModel.id,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
