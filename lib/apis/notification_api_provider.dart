import 'package:appwrite/appwrite.dart';
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
  Future<NotificationModel> create(
    NotificationModel notification, {
    bool isCustomError = true,
  }) async {
    return await _db
        .createDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: ID.unique(),
          data: notification.toMap(),
        )
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => isCustomError ? errorMessage(error: e) : throw e);
  }

  /// 単一取得
  Future<NotificationModel> get(String id, {bool isCustomError = true}) async {
    return await _db
        .getDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: id,
        )
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => isCustomError ? errorMessage(error: e) : throw e);
  }

  /// リスト取得
  Future<List<NotificationModel>> getList({
    List<String>? queries,
    bool isCustomError = true,
  }) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          queries: queries,
        )
        .then((docs) => docs.documents.map((doc) => NotificationModel.fromMap(doc.data)).toList())
        .catchError((e) => isCustomError ? errorMessage(error: e) : throw e);
  }

  /// 更新
  Future<NotificationModel> update(
    NotificationModel notification, {
    bool isCustomError = true,
  }) async {
    return await _db
        .updateDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: notification.documentId!,
          data: notification.toMap(),
        )
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => isCustomError ? errorMessage(error: e) : throw e);
  }
}
