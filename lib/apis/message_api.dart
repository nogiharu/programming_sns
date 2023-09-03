import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/core/dependencies.dart';
import 'package:programming_sns/extensions/message_ex.dart';

final messageAPIProvider = Provider(
  (ref) => MessageAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class MessageAPI {
  final Databases _db;
  MessageAPI({required Databases db}) : _db = db;

  // Future<Document> getUserDocument(String id) async {
  //   return await _db.getDocument(
  //     databaseId: AppwriteConstants.databaseId,
  //     collectionId: AppwriteConstants.usersCollection,
  //     documentId: id,
  //   );
  // }

  Future<Document> createMessageDocument(Message message) async {
    return await _db.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.messagesCollection,
      documentId: ID.unique(),
      data: message.toMap(),
    );
  }

  Future<DocumentList> getMessagesDocumentList() async {
    return await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.messagesCollection,
      queries: [
        Query.orderAsc('createdAt'),
      ],
    );
  }
}
