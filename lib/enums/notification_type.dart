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
