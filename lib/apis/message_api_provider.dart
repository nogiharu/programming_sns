import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/features/chat/models/message_ex.dart';
import 'package:programming_sns/common/utils.dart';

final messageAPIProvider = Provider(
  (ref) => MessageAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class MessageAPI {
  final Databases _db;
  MessageAPI({required Databases db}) : _db = db;

  Future<Message> create(Message message, {bool isDefaultError = false}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: ID.unique(),
          data: message.toMap(),
        )
        .then((doc) => MessageEX.fromMap(doc.data))
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<Message> update(Message message, {bool isDefaultError = false}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: message.id,
          data: message.toMap(),
        )
        .then((doc) => MessageEX.fromMap(doc.data))
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<List<Message>> getList({List<String>? queries, isDefaultError = false}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          queries: queries,
        )
        .then((docs) => docs.documents.map((doc) => MessageEX.fromMap(doc.data)).toList())
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  Future<dynamic> delete(String id, {bool isDefaultError = false}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: id,
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }
}
