import 'dart:convert';

import 'package:programming_sns/enums/notification_type.dart';

class NotificationModel {
  String? documentId;
  final String userId;
  final String text;
  final NotificationType notificationType;
  String? messageId;
  String? chatRoomId;
  final DateTime createdAt;
  final bool isRead;
  final String sendByUserName;
  NotificationModel({
    this.documentId,
    required this.userId,
    required this.text,
    required this.notificationType,
    this.messageId,
    this.chatRoomId,
    required this.createdAt,
    required this.isRead,
    required this.sendByUserName,
  });

  NotificationModel copyWith({
    String? documentId,
    String? userId,
    String? text,
    NotificationType? notificationType,
    String? messageId,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    String? sendByUserName,
  }) {
    return NotificationModel(
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      notificationType: notificationType ?? this.notificationType,
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      sendByUserName: sendByUserName ?? this.sendByUserName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (documentId != null) {
      result.addAll({'documentId': documentId});
    }
    result.addAll({'userId': userId});
    result.addAll({'text': text});
    result.addAll({'notificationType': notificationType.toString()});
    if (messageId != null) {
      result.addAll({'messageId': messageId});
    }
    if (chatRoomId != null) {
      result.addAll({'chatRoomId': chatRoomId});
    }
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'isRead': isRead});
    result.addAll({'sendByUserName': sendByUserName});

    return result;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      documentId: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      notificationType: (map['notificationType'] as String).toNotificationTypeEnum(),
      messageId: map['messageId'],
      chatRoomId: map['chatRoomId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
      sendByUserName: map['sendByUserName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NotificationModel(documentId: $documentId, userId: $userId, text: $text, notificationType: $notificationType, messageId: $messageId, chatRoomId: $chatRoomId, createdAt: $createdAt, isRead: $isRead, sendByUserName: $sendByUserName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.documentId == documentId &&
        other.userId == userId &&
        other.text == text &&
        other.notificationType == notificationType &&
        other.messageId == messageId &&
        other.chatRoomId == chatRoomId &&
        other.createdAt == createdAt &&
        other.isRead == isRead &&
        other.sendByUserName == sendByUserName;
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
        userId.hashCode ^
        text.hashCode ^
        notificationType.hashCode ^
        messageId.hashCode ^
        chatRoomId.hashCode ^
        createdAt.hashCode ^
        isRead.hashCode ^
        sendByUserName.hashCode;
  }

  factory NotificationModel.instance({
    String? userId,
    String? text,
    NotificationType? notificationType,
    String? messageId,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    // String? sendByUserId,
    String? sendByUserName,
  }) =>
      NotificationModel(
        userId: userId ?? '',
        text: text ?? '',
        notificationType: notificationType ?? NotificationType.reaction,
        messageId: messageId ?? '',
        chatRoomId: chatRoomId ?? '',
        createdAt: DateTime.now(),
        isRead: isRead ?? false,
        sendByUserName: sendByUserName ?? '',
      );
}
