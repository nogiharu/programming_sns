import 'package:chatview/chatview.dart';
import 'package:programming_sns/enums/message_type_ex.dart';

extension MessageEX on Message {
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    if (id != null) {
      result.addAll({'id': id});
    }
    result.addAll({'send_by_user_id': sendBy});
    result.addAll({'chat_room_id': chatRoomId});
    result.addAll({'message': message});
    result.addAll({'message_type': messageType.toString()});
    result.addAll({'reactions': reaction.reactions});
    result.addAll({'reacted_user_ids': reaction.reactedUserIds});
    result.addAll({'is_deleted': isDeleted ?? false});

    return result;
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      sendBy: map['send_by_user_id'],
      chatRoomId: map['chat_room_id'] ?? '',
      message: map['message'] ?? '',
      messageType: (map['message_type'] as String).messageTypeToEnum(),
      reaction: Reaction(
        reactions: List<String>.from(map['reactions']),
        reactedUserIds: List<String>.from(map['reacted_user_ids']),
      ),
      isDeleted: map['is_deleted'] ?? false,
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      replyMessage: const ReplyMessage(),
      // ReplyMessage(
      //   messageId: map['message_id'] ?? '',
      //   replyBy: map['reply_by_user_id'] ?? '',
      //   replyTo: map['send_by_user_id'] ?? '',
      //   message: map['reply_message'] ?? '',
      //   messageType: (map['reply_message_type'] as String).messageTypeToEnum(),
      // ),
      status: MessageStatus.read,
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
    bool? isDeleted,
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
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
