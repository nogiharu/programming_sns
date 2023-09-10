import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:programming_sns/core/enums/message_status_ex.dart';
import 'package:programming_sns/core/enums/message_type_ex.dart';

extension MessageEX on Message {
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'message': message});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'sendByUserId': sendBy});
    result.addAll({'messageType': messageType.toString()});
    result.addAll({'reactions': reaction.reactions});
    result.addAll({'reactedUserIds': reaction.reactedUserIds});
    result.addAll({'replyByUserId': replyMessage.replyBy});
    result.addAll({'replyToUserId': replyMessage.replyTo});
    result.addAll({'replyMessageType': replyMessage.messageType.toString()});
    result.addAll({'replyMessageId': replyMessage.messageId});
    result.addAll({'replyMessage': replyMessage.message});
    result.addAll({'status': status.toString()});
    return result;
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['\$id'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      sendBy: map['sendByUserId'],
      messageType: (map['messageType'] as String).messageTypeToEnum(),
      reaction: Reaction(
        reactions: List<String>.from(map['reactions']),
        reactedUserIds: List<String>.from(map['reactedUserIds']),
      ),
      replyMessage: ReplyMessage(
        replyBy: map['replyByUserId'],
        replyTo: map['replyToUserId'],
        messageType: (map['replyMessageType'] as String).messageTypeToEnum(),
        messageId: map['replyMessageId'],
        message: map['replyMessage'] ?? '',
      ),
      status: (map['status'] as String).messageStatusToEnum(),
    );
  }
}
