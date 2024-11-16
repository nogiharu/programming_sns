import 'package:chatview/chatview.dart';

extension ConvertMessageStatus on String {
  MessageStatus messageStatusToEnum() {
    switch (this) {
      // case 'MessageStatus.pending':
      //   return MessageStatus.pending;
      // case 'MessageStatus.delivered':
      //   return MessageStatus.delivered;
      // case 'MessageStatus.undelivered':
      //   return MessageStatus.undelivered;
      default:
        return MessageStatus.read;
    }
  }
}

extension ConvertMessageType on String {
  MessageType messageTypeToEnum() {
    switch (this) {
      case 'MessageType.text':
        return MessageType.text;
      case 'MessageType.image':
        return MessageType.image;
      case 'MessageType.custom':
        return MessageType.custom;
      default:
        return MessageType.custom;
    }
  }
}

enum NotificationType {
  reaction('リアクション'),
  mention('メンション');

  final String type;
  const NotificationType(this.type);

  @override
  String toString() => type.toString();
}

extension ConvertNotification on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {
      case 'reaction':
        return NotificationType.reaction;
      case 'メンション':
        return NotificationType.mention;
      default:
        return NotificationType.mention;
    }
  }
}
