import 'package:chatview/chatview.dart';

extension ConvertMessageType on String {
  MessageType messageTypeToEnum() {
    switch (this) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'custom':
        return MessageType.custom;
      default:
        return MessageType.custom;
    }
  }
}
