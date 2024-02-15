import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/utils/exception_message.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

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
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: id,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> createUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: userModel.id,
          data: userModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> updateUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: userModel.id,
          data: userModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<DocumentList> getUsersDocumentList({String? chatRoomId, bool isCatch = true}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          queries: chatRoomId == null
              ? []
              : [
                  Query.search('chatRoomIds', chatRoomId),
                  Query.limit(10000),
                ],
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> deleteUserDocument(UserModel userModel, {bool isCatch = true}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: userModel.id,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
