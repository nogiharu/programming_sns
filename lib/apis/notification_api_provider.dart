import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:programming_sns/constants/appwrite_constants.dart';
import 'package:programming_sns/core/appwrite_providers.dart';
import 'package:programming_sns/common/utils.dart';
import 'package:programming_sns/features/notification/models/notification_model.dart';

final notificationAPIProvider = Provider(
  (ref) => NotificationAPI(
    db: ref.watch(appwriteDatabaseProvider),
  ),
);

class NotificationAPI {
  final Databases _db;
  NotificationAPI({required Databases db}) : _db = db;

  /// 作成
  Future<Document> createNotificationDocument(
    NotificationModel notificationModel, {
    isDefaultError = false,
  }) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: ID.unique(),
          data: notificationModel.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// 取得
  Future<Document> getNotificationDocument(String id, {bool isDefaultError = false}) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.kDatabaseId,
      collectionId: AppwriteConstants.kNotificationCollection,
      documentId: id,
      queries: [],
    ).catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// リスト取得
  Future<DocumentList> getNotificationDocumentList(
      {List<String>? queries, isDefaultError = false}) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          queries: queries,
          // [
          //   Query.orderDesc('createdAt'),
          //   Query.limit(10000), // FIXME
          // ],
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// 更新
  Future<Document> updateNotificationDocument(
    NotificationModel notificationModel, {
    isDefaultError = false,
  }) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: notificationModel.documentId!,
          data: notificationModel.toMap(),
        )
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }
}
