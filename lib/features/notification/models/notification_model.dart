import 'package:programming_sns/enums/notification_type.dart';

class NotificationModel {
  String? id;
  final String userId;
  final String message;
  final NotificationType notificationType;

  String? chatRoomId;
  final DateTime createdAt;
  final bool isRead;
  final String sendByUserName;
  final String chatRoomName;

  NotificationModel({
    this.id,
    required this.userId,
    required this.message,
    required this.notificationType,
    this.chatRoomId,
    required this.createdAt,
    required this.isRead,
    required this.sendByUserName,
    required this.chatRoomName,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? text,
    NotificationType? notificationType,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    String? sendByUserName,
    String? chatRoomLabel,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: text ?? message,
      notificationType: notificationType ?? this.notificationType,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      sendByUserName: sendByUserName ?? this.sendByUserName,
      chatRoomName: chatRoomLabel ?? chatRoomName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    if (id != null) {
      result.addAll({'id': id});
    }

    result.addAll({'user_id': userId});
    result.addAll({'is_read': isRead});

    result.addAll({'message': message});
    result.addAll({'send_by_user_name': sendByUserName});
    result.addAll({'chat_room_id': chatRoomId});
    result.addAll({'chat_room_name': chatRoomName});
    result.addAll({'created_at': createdAt.toUtc().toIso8601String()});

    result.addAll({'notification_type': notificationType.toString()});

    return result;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      message: map['message'] ?? '',
      notificationType: (map['notification_type'] as String).toNotificationTypeEnum(),
      chatRoomId: map['chat_room_id'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      isRead: map['is_read'] ?? false,
      sendByUserName: map['send_by_user_name'] ?? '',
      chatRoomName: map['chat_room_name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, text: $message, notificationType: $notificationType, chatRoomId: $chatRoomId, createdAt: $createdAt, isRead: $isRead, sendByUserName: $sendByUserName, chatRoomLabel: $chatRoomName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.message == message &&
        other.notificationType == notificationType &&
        other.chatRoomId == chatRoomId &&
        other.createdAt == createdAt &&
        other.isRead == isRead &&
        other.sendByUserName == sendByUserName &&
        other.chatRoomName == chatRoomName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        message.hashCode ^
        notificationType.hashCode ^
        chatRoomId.hashCode ^
        createdAt.hashCode ^
        isRead.hashCode ^
        sendByUserName.hashCode ^
        chatRoomName.hashCode;
  }

  factory NotificationModel.instance({
    String? userId,
    String? message,
    NotificationType? notificationType,
    String? chatRoomId,
    DateTime? createdAt,
    bool? isRead,
    String? sendByUserName,
    String? chatRoomName,
  }) =>
      NotificationModel(
        userId: userId ?? '',
        message: message ?? '',
        notificationType: notificationType ?? NotificationType.mention,
        chatRoomId: chatRoomId ?? '',
        createdAt: createdAt ?? DateTime.now(),
        isRead: isRead ?? false,
        sendByUserName: sendByUserName ?? '',
        chatRoomName: chatRoomName ?? '',
      );
}
