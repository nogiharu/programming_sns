import 'package:chatview/chatview.dart';

class ChatRoomModel {
  final String? id;
  final String ownerId;
  final String name;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  ChatRoomModel({
    this.id,
    required this.ownerId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  ChatRoomModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    if (id != null) {
      result.addAll({'id': id});
    }

    result.addAll({'users_id': ownerId});
    result.addAll({'name': name});
    return result;
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'] ?? '',
      ownerId: map['users_id'] ?? '',
      name: map['name'] ?? '',
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
    );
  }

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, ownerId: $ownerId, name: $name,  $createdAt, updatedAt: $updatedAt )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ ownerId.hashCode ^ name.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
  }

  factory ChatRoomModel.instance({
    String? ownerId,
    String? name,
  }) =>
      ChatRoomModel(
        ownerId: ownerId ?? '',
        name: name ?? '',
        // createdAt: DateTime.now(),
        // updatedAt: DateTime.now(),
      );
}
