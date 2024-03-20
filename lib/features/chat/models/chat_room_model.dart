import 'package:chatview/chatview.dart';

class ChatRoomModel {
  String? documentId;
  final String ownerId;
  final String name;
  // List<Message>? messages;

  final DateTime createdAt;

  final DateTime updatedAt;

  ChatRoomModel({
    this.documentId,
    required this.ownerId,
    required this.name,
    // this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatRoomModel copyWith({
    String? documentId,
    String? ownerId,
    String? name,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      documentId: documentId ?? this.documentId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      // messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'ownerId': ownerId});
    result.addAll({'name': name});
    // if (messages != null) {
    //   result.addAll({'messages': messages!.map((x) => x.toMap()).toList()});
    // }
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    return result;
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      documentId: map['\$id'],
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      // messages: map['messages'] != null
      //     ? List<Message>.from(map['messages']?.map((x) => MessageEX.fromMap(x)))
      //     : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'ChatRoomModel(id: $documentId, ownerId: $ownerId, name: $name,  $createdAt, updatedAt: $updatedAt )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomModel &&
        other.documentId == documentId &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
    // listEquals(other.messages, messages);
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
        ownerId.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
    // messages.hashCode;
  }

  factory ChatRoomModel.instance({
    String? ownerId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ChatRoomModel(
        ownerId: ownerId ?? '',
        name: name ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
