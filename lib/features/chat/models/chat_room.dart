import 'dart:convert';

class ChatRoom {
  String? id;
  final String ownerId;
  final String name;
  ChatRoom({
    this.id,
    required this.ownerId,
    required this.name,
  });

  ChatRoom copyWith({
    String? id,
    String? ownerId,
    String? name,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'ownerId': ownerId});
    result.addAll({'name': name});

    return result;
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['\$id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
    );
  }

  @override
  String toString() => 'ChatRoom(id: $id, ownerId: $ownerId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom && other.id == id && other.ownerId == ownerId && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ ownerId.hashCode ^ name.hashCode;
}
