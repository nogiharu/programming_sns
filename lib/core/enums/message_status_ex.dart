import 'package:chatview/chatview.dart';

extension ConvertMessageStatus on String {
  MessageStatus messageStatusToEnum() {
    switch (this) {
      case 'pending':
        return MessageStatus.pending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'undelivered':
        return MessageStatus.undelivered;
      default:
        return MessageStatus.read;
    }
  }
}
