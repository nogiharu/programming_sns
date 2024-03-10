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
    bool isCatch = true,
  }) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: ID.unique(),
          data: notificationModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// 取得
  Future<Document> getNotificationDocument(String id, {bool isCatch = true}) async {
    return await _db.getDocument(
      databaseId: AppwriteConstants.kDatabaseId,
      collectionId: AppwriteConstants.kNotificationCollection,
      documentId: id,
      queries: [],
    ).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// リスト取得
  Future<DocumentList> getNotificationDocumentList({bool isCatch = true}) async {
    return await _db.listDocuments(
      databaseId: AppwriteConstants.kDatabaseId,
      collectionId: AppwriteConstants.kNotificationCollection,
      queries: [
        Query.orderDesc('createdAt'),
        Query.limit(10000), // FIXME
      ],
    ).catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }

  /// 更新
  Future<Document> updateNotificationDocument(
    NotificationModel notificationModel, {
    bool isCatch = true,
  }) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: notificationModel.id,
          data: notificationModel.toMap(),
        )
        .catchError((e) => isCatch ? exceptionMessage(error: e) : throw e);
  }
}
