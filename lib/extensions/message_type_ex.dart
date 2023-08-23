import 'package:chatview/chatview.dart';

extension ConvertMessageType on MessageType {
  String messageTypeToString() {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.custom:
        return 'custom';
      default:
        return 'custom';
    }
  }
}
