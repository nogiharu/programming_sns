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
  Future<NotificationModel> create(
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
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// 単一取得
  Future<NotificationModel> get(String id, {bool isDefaultError = false}) async {
    return await _db
        .getDocument(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          documentId: id,
        )
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// リスト取得
  Future<List<NotificationModel>> getList({
    List<String>? queries,
    isDefaultError = false,
  }) async {
    return await _db
        .listDocuments(
          databaseId: AppwriteConstants.kDatabaseId,
          collectionId: AppwriteConstants.kNotificationCollection,
          queries: queries,
        )
        .then((docs) => docs.documents.map((doc) => NotificationModel.fromMap(doc.data)).toList())
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }

  /// 更新
  Future<NotificationModel> update(
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
        .then((doc) => NotificationModel.fromMap(doc.data))
        .catchError((e) => exceptionMessage(error: e, isDefaultError: isDefaultError));
  }
}
