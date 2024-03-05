enum NotificationType {
  reaction('reaction'),
  mention('mention');

  final String type;
  const NotificationType(this.type);
}

extension ConvertNotification on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {
      case 'reaction':
        return NotificationType.reaction;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.reaction;
    }
  }
}
