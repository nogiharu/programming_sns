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
