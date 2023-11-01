import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/features/chat/models/chat_room.dart';
import 'package:programming_sns/features/user/models/user_model.dart';

final chatRoomAPIProvider = Provider(
  (ref) => ChatRoomAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class ChatRoomAPI {
  final Databases _db;
  ChatRoomAPI({required Databases db}) : _db = db;

  Future<Document> getChatRoomDocument(String id) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.chatRoomCollection,
      documentId: id,
    );
  }

  Future<Document> createChatRoomDocument(ChatRoom chatRoom) async {
    return await _db.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.chatRoomCollection,
      documentId: ID.unique(),
      data: chatRoom.toMap(),
    );
  }
}
