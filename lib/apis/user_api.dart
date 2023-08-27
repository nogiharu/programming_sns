import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/providers.dart';
import 'package:programming_sns/models/user_model.dart';

final userAPIProvider = Provider(
  (ref) => UserAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class UserAPI {
  final Databases _db;
  UserAPI({required Databases db}) : _db = db;

  Future<Document> getUserDocument(String id) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: id,
    );
  }

  Future<Document> createUserDocument(UserModel userModel) async {
    return await _db.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: userModel.id,
      data: userModel.toMap(),
    );
  }

  Future<Document> updateUserDocument(UserModel userModel) async {
    return await _db.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.usersCollection,
      documentId: userModel.id,
      data: userModel.toMap(),
    );
  }
}
