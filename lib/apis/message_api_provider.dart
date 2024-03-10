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

  Future<DocumentList> getFirstMessageDocument({
    required String chatRoomId,
    bool isCatch = true,
  }) async {
    return await _db.listDocuments(
      databaseId: AppwriteConstants.kDatabaseId,
      collectionId: AppwriteConstants.kMessagesCollection,
      queries: [
        Query.equal('chatRoomId', chatRoomId),
        Query.orderAsc('createdAt'),
        Query.limit(1),
      ],
    ).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> createMessageDocument(Message message, {bool isCatch = true}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: ID.unique(),
          data: message.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<Document> updateMessageDocument(Message message, {bool isCatch = true}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: message.id,
          data: message.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<DocumentList> getMessagesDocumentList(
      {required String chatRoomId, String? id, bool isCatch = true}) async {
    final queries = [
      Query.orderDesc('createdAt'),
      Query.equal('chatRoomId', chatRoomId),
      Query.limit(25),
    ];

    // idより前を取得
    if (id != null) queries.add(Query.cursorAfter(id));

    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          queries: queries,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  Future<dynamic> deleteMessageDocument(String id, {bool isCatch = true}) async {
    return await _db
        .deleteDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kMessagesCollection,
          documentId: id,
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
