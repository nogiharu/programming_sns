import 'package:chatview/chatview.dart';
import 'package:programming_sns/enums/message_status_ex.dart';
import 'package:programming_sns/enums/message_type_ex.dart';

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
    result.addAll({'chatRoomId': chatRoomId});
    result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});

    return result;
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['\$id'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      // createdAt: DateTime.parse(map['\$createdAt']),
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
      chatRoomId: map['chatRoomId'] ?? '',
      updatedAt: map['updatedAt'] != null // FIXME
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Message copyWith({
    String? id,
    String? message,
    DateTime? createdAt,
    String? sendBy,
    ReplyMessage? replyMessage,
    Reaction? reaction,
    MessageType? messageType,
    Duration? voiceMessageDuration,
    String? chatRoomId,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      sendBy: sendBy ?? this.sendBy,
      replyMessage: replyMessage ?? this.replyMessage,
      reaction: reaction ?? this.reaction,
      messageType: messageType ?? this.messageType,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
