import 'package:chatview/chatview.dart';
import 'package:programming_sns/extensions/message_type_ex.dart';

extension MessageEx on Message {
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'message': message});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'sendByUserId': sendBy});
    result.addAll({'messageType': messageType.messageTypeToString()});
    result.addAll({'reactions': reaction.reactions});
    result.addAll({'reactedUserIds': reaction.reactedUserIds});
    result.addAll({'replyByUserId': replyMessage.replyBy});
    result.addAll({'replyToUserId': replyMessage.replyTo});
    result.addAll({'replyMessageType': replyMessage.messageType.messageTypeToString()});
    result.addAll({'replyMessageId': replyMessage.messageId});
    return result;
  }

  // static Message fromMap(Map<String, dynamic> map) {
  //   return Message(
  //     title: '',
  //     message: message,
  //     createdAt: createdAt,
  //     sendBy: sendBy,
  //   );
  // }
}
