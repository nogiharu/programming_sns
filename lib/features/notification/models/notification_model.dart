import 'package:programming_sns/enums/notification_type.dart';

class NotificationModel {
  String? documentId;
  final String userDocumentId;
  final String text;
  final NotificationType notificationType;

  String? chatRoomId;
  final DateTime createdAt;
  final bool isRead;
  final String sendByUserName;
  final String chatRoomLabel;

  NotificationModel({
    this.documentId,
    required this.userDocumentId,
    required this.text,
    required this.notificationType,
    this.chatRoomId,
    required this.createdAt,
    required this.isRead,
    required this.sendByUserName,
    required this.chatRoomLabel,
  });

  NotificationModel copyWith({
    String? documentId,
    String? userDocumentId,
    String? text,
    NotificationType? notificationType,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    String? sendByUserName,
    String? chatRoomLabel,
  }) {
    return NotificationModel(
      documentId: documentId ?? this.documentId,
      userDocumentId: userDocumentId ?? this.userDocumentId,
      text: text ?? this.text,
      notificationType: notificationType ?? this.notificationType,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      sendByUserName: sendByUserName ?? this.sendByUserName,
      chatRoomLabel: chatRoomLabel ?? this.chatRoomLabel,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'userDocumentId': userDocumentId});
    result.addAll({'text': text});
    result.addAll({'notificationType': notificationType.toString()});

    if (chatRoomId != null) {
      result.addAll({'chatRoomId': chatRoomId});
    }
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'isRead': isRead});
    result.addAll({'sendByUserName': sendByUserName});
    result.addAll({'chatRoomLabel': chatRoomLabel});

    return result;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      documentId: map['\$id'],
      userDocumentId: map['userDocumentId'] ?? '',
      text: map['text'] ?? '',
      notificationType: (map['notificationType'] as String).toNotificationTypeEnum(),
      chatRoomId: map['chatRoomId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
      sendByUserName: map['sendByUserName'] ?? '',
      chatRoomLabel: map['chatRoomLabel'] ?? '',
    );
  }

  @override
  String toString() {
    return 'NotificationModel(documentId: $documentId, userDocumentId: $userDocumentId, text: $text, notificationType: $notificationType, chatRoomId: $chatRoomId, createdAt: $createdAt, isRead: $isRead, sendByUserName: $sendByUserName, chatRoomLabel: $chatRoomLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.documentId == documentId &&
        other.userDocumentId == userDocumentId &&
        other.text == text &&
        other.notificationType == notificationType &&
        other.chatRoomId == chatRoomId &&
        other.createdAt == createdAt &&
        other.isRead == isRead &&
        other.sendByUserName == sendByUserName &&
        other.chatRoomLabel == chatRoomLabel;
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
        userDocumentId.hashCode ^
        text.hashCode ^
        notificationType.hashCode ^
        chatRoomId.hashCode ^
        createdAt.hashCode ^
        isRead.hashCode ^
        sendByUserName.hashCode ^
        chatRoomLabel.hashCode;
  }

  factory NotificationModel.instance({
    String? userDocumentId,
    String? text,
    NotificationType? notificationType,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    String? sendByUserName,
    String? chatRoomLabel,
  }) =>
      NotificationModel(
        userDocumentId: userDocumentId ?? '',
        text: text ?? '',
        notificationType: notificationType ?? NotificationType.mention,
        chatRoomId: chatRoomId ?? '',
        createdAt: createdAt ?? DateTime.now(),
        isRead: isRead ?? false,
        sendByUserName: sendByUserName ?? '',
        chatRoomLabel: chatRoomLabel ?? '',
      );
}
