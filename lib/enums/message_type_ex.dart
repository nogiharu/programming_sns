import 'package:chatview/chatview.dart';

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
