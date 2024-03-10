import 'package:programming_sns/enums/notification_type.dart';

class NotificationModel {
  final String id;
  final String text;
  final NotificationType notificationType;
  final String messageId;
  final String chatRoomId;
  final DateTime createdAt;
  NotificationModel({
    required this.id,
    required this.text,
    required this.notificationType,
    required this.messageId,
    required this.chatRoomId,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? text,
    NotificationType? notificationType,
    String? messageId,
    String? chatRoomId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      text: text ?? this.text,
      notificationType: notificationType ?? this.notificationType,
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'text': text});
    result.addAll({'notificationType': notificationType.toString()});
    result.addAll({'messageId': messageId});
    result.addAll({'chatRoomId': chatRoomId});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});

    return result;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      notificationType: (map['notificationType'] as String).toNotificationTypeEnum(),
      messageId: map['messageId'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, text: $text, notificationType: $notificationType, messageId: $messageId, chatRoomId: $chatRoomId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.text == text &&
        other.notificationType == notificationType &&
        other.messageId == messageId &&
        other.chatRoomId == chatRoomId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        notificationType.hashCode ^
        messageId.hashCode ^
        chatRoomId.hashCode ^
        createdAt.hashCode;
  }

  factory NotificationModel.instance({
    String? id,
    String? text,
    NotificationType? notificationType,
    String? messageId,
    String? chatRoomId,
    DateTime? createdAt,
  }) =>
      NotificationModel(
        id: id ?? '',
        text: text ?? '',
        notificationType: notificationType ?? NotificationType.reaction,
        messageId: messageId ?? '',
        chatRoomId: chatRoomId ?? '',
        createdAt: DateTime.now(),
      );
}
