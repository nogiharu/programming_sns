import 'package:chatview/chatview.dart';
import 'package:programming_sns/core/enums.dart';

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
    result.addAll({'is_deleted': isDeleted ?? false});
    result.addAll({'updated_at': DateTime.now().toUtc().toIso8601String()});
    result.addAll({'created_at': createdAt.toUtc().toIso8601String()});

    Map<String, dynamic> reactions = {};
    List.generate(reaction.reactedUserIds.length, (index) {
      reactions[reaction.reactedUserIds[index]] = reaction.reactions[index];
    });
    result.addAll({'reactions': reactions});

    if (replyMessage.messageId.isNotEmpty) {
      result.addAll({
        'reply_to': {
          'message_id': replyMessage.messageId,
          'user_id': replyMessage.replyTo,
          'message_type': replyMessage.messageType.toString(),
          'message': replyMessage.message
        }
      });
    }
    result.addAll({'read_user_ids': readUserIds});

    return result;
  }

  static Message fromMap(Map<String, dynamic> map) {
    List<String> reactions = [];
    List<String> reactedUserIds = [];

    if (map['reactions'] is Map<String, dynamic>) {
      (map['reactions'] as Map<String, dynamic>).forEach((k, v) {
        reactedUserIds.add(k);
        reactions.add(v);
      });
    }

    ReplyMessage replyMessage = const ReplyMessage();
    if (map['reply_to'] is Map<String, dynamic>) {
      replyMessage = ReplyMessage(
        messageId: map['reply_to']['message_id'] ?? '',
        replyTo: map['reply_to']['user_id'] ?? '',
        message: map['reply_to']['message'] ?? '',
        messageType: map['reply_to']['message_type'] != null
            ? (map['message_type'] as String).messageTypeToEnum()
            : MessageType.text,
        replyBy: map['send_by_user_id'] ?? '',
      );
    }

    return Message(
      id: map['id'] ?? '',
      sendBy: map['send_by_user_id'],
      chatRoomId: map['chat_room_id'] ?? '',
      message: map['message'] ?? '',
      messageType: (map['message_type'] as String).messageTypeToEnum(),
      reaction: Reaction(
        reactions: reactions,
        reactedUserIds: reactedUserIds,
      ),
      isDeleted: map['is_deleted'] ?? false,
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      replyMessage: replyMessage,
      status: MessageStatus.read,
      readUserIds: List<String>.from(map['read_user_ids'] ?? []),
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
    MessageStatus? status,
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
      status: status ?? this.status,
    );
  }
}
