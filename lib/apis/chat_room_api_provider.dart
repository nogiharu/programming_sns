import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/utils/exception_message.dart';
import 'package:programming_sns/features/chat/models/chat_room.dart';

final chatRoomAPIProvider = Provider(
  (ref) => ChatRoomAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class ChatRoomAPI {
  final Databases _db;
  ChatRoomAPI({required Databases db}) : _db = db;

  /// チャットルーム作成
  Future<Document> createChatRoomDocument(ChatRoom chatRoom, {bool isCatch = true}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.chatRoomCollection,
          documentId: ID.unique(),
          data: chatRoom.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// チャットルーム取得
  Future<Document> getChatRoomDocument(String id, {bool isCatch = true}) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.chatRoomCollection,
      documentId: id,
      queries: [],
    ).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// チャットルームリスト取得
  Future<DocumentList> getChatRoomDocumentList({bool isCatch = true}) async {
    return await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.chatRoomCollection,
      queries: [
        Query.orderDesc('updatedAt'),
        Query.limit(10000), // FIXME
      ],
    ).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// チャットルーム更新
  Future<Document> updateChatRoomDocument(ChatRoom chatRoom, {bool isCatch = true}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.chatRoomCollection,
          documentId: chatRoom.id!,
          data: chatRoom.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
