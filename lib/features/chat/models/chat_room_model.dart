class ChatRoomModel {
  final String? id;
  final String ownerId;
  final String name;

  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> memberUserIds;

  ChatRoomModel({
    this.id,
    required this.ownerId,
    required this.name,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    required this.memberUserIds,
  });

  ChatRoomModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? memberUserIds,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberUserIds: memberUserIds ?? this.memberUserIds,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    if (id != null) {
      result.addAll({'id': id});
    }

    result.addAll({'owner_user_id': ownerId});
    result.addAll({'member_user_ids': memberUserIds});
    result.addAll({'name': name});
    result.addAll({'is_deleted': isDeleted});
    result.addAll({'updated_at': DateTime.now().toString()});

    return result;
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'] ?? '',
      ownerId: map['owner_user_id'] ?? '',
      memberUserIds: List<String>.from(map['member_user_ids'] ?? []),
      name: map['name'] ?? '',
      isDeleted: map['is_deleted'] ?? false,
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
    );
  }

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, ownerId: $ownerId, memberUserIds: $memberUserIds, name: $name, isDeleted: $isDeleted, $createdAt, updatedAt: $updatedAt )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ownerId.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isDeleted.hashCode;
  }

  factory ChatRoomModel.instance({
    String? ownerId,
    String? name,
    List<String>? memberUserIds,
    bool? isDeleted,
  }) =>
      ChatRoomModel(
        ownerId: ownerId ?? '',
        name: name ?? '',
        isDeleted: isDeleted ?? false,
        memberUserIds: memberUserIds ?? [],
      );
}
