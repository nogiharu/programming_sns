import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/features/chat/models/chat_room_model.dart';
import 'package:programming_sns/common/utils.dart';

final chatRoomAPIProvider = Provider(
  (ref) => ChatRoomAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class ChatRoomAPI {
  final Databases _db;
  ChatRoomAPI({required Databases db}) : _db = db;

  /// チャットルーム作成
  Future<Document> createChatRoomDocument(ChatRoomModel chatRoom,
      {bool isDefaultError = false}) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kChatRoomCollection,
          documentId: ID.unique(),
          data: chatRoom.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// チャットルーム取得
  Future<Document> getChatRoomDocument(String id, {bool isDefaultError = false}) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.kDatabaseId,
      collectionId: AppwriteConstants.kChatRoomCollection,
      documentId: id,
      queries: [],
    ).catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// チャットルームリスト取得
  Future<DocumentList> getChatRoomDocumentList(
      {List<String>? queries, isDefaultError = false}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kChatRoomCollection,
          queries: queries,
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// チャットルーム更新
  Future<Document> updateChatRoomDocument(ChatRoomModel chatRoom,
      {bool isDefaultError = false}) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kChatRoomCollection,
          documentId: chatRoom.documentId!,
          data: chatRoom.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }
}
