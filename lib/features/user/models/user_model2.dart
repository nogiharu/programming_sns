// ignore_for_file: overridden_fields

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/foundation.dart';

class UserModel {
  final String id;

  final String name;

  final String? profilePhoto;

  final DateTime createdAt;

  final DateTime updatedAt;

  /// ユーザが変えられるID　メンションに使用
  final String userId;

  final bool isDeleted;

  List<String>? chatRoomIds;

  UserModel({
    required this.id,
    required this.name,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.isDeleted,
    this.chatRoomIds,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isDeleted,
    List<String>? chatRoomIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      chatRoomIds: chatRoomIds ?? this.chatRoomIds,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'profile_photo': profilePhoto});

    result.addAll({'user_id': userId});

    result.addAll({'is_deleted': isDeleted});
    if (chatRoomIds != null) {
      result.addAll({'chat_room_ids': chatRoomIds});
    }
    print('ああああ：$result');
    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      profilePhoto: map['profile_photo'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      userId: map['user_id'],
      isDeleted: map['is_deleted'],
      chatRoomIds: List<String>.from(map['chat_room_ids'] ?? []),
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isDeleted: $isDeleted chatRoomIds: $chatRoomIds )';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.profilePhoto == profilePhoto &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        listEquals(other.chatRoomIds, chatRoomIds) &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      profilePhoto.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      userId.hashCode ^
      chatRoomIds.hashCode ^
      isDeleted.hashCode;

  factory UserModel.instance({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? password,
    String? userId,
    bool? isAnonymous,
    List<String>? chatRoomIds,
    bool? isDeleted,
  }) {
    return UserModel(
      id: id ?? '',
      name: name ?? '名前はまだない',
      profilePhoto:
          "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png",
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId ?? '',
      isDeleted: isDeleted ?? false,
      chatRoomIds: chatRoomIds ?? [],
    );
  }

  static ChatUser toChatUser(UserModel userModel) {
    return ChatUser(
      id: userModel.id,
      name: userModel.name,
      profilePhoto: userModel.profilePhoto,
      userId: userModel.userId,
    );
  }
}
