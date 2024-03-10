// ignore_for_file: overridden_fields

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String id;

  final String name;

  final String profilePhoto;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String loginPassword;

  final String userId;

  final bool isAnonymous;

  // final bool isDeleted;
  List<String>? chatRoomIds;

  UserModel({
    required this.id,
    required this.name,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.loginPassword,
    required this.userId,
    required this.isAnonymous,
    this.chatRoomIds,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? loginPassword,
    String? userId,
    bool? isAnonymous,
    List<String>? chatRoomIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      loginPassword: loginPassword ?? this.loginPassword,
      userId: userId ?? this.userId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      chatRoomIds: chatRoomIds ?? this.chatRoomIds,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    result.addAll({'profilePhoto': profilePhoto});

    result.addAll({'loginPassword': loginPassword});
    result.addAll({'userId': userId});

    result.addAll({'isAnonymous': isAnonymous});
    if (chatRoomIds != null) {
      result.addAll({'chatRoomIds': chatRoomIds});
    }

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      loginPassword: map['loginPassword'] ?? '',
      userId: map['userId'] ?? '',
      isAnonymous: map['isAnonymous'] ?? true,
      chatRoomIds: List<String>.from(map['chatRoomIds']),
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto, createdAt: $createdAt, updatedAt: $updatedAt, loginPassword: $loginPassword, userId: $userId, isAnonymous: $isAnonymous   chatRoomIds: $chatRoomIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.profilePhoto == profilePhoto &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.loginPassword == loginPassword &&
        other.userId == userId &&
        other.isAnonymous == isAnonymous &&
        listEquals(other.chatRoomIds, chatRoomIds);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      profilePhoto.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      loginPassword.hashCode ^
      userId.hashCode ^
      isAnonymous.hashCode ^
      chatRoomIds.hashCode;

  factory UserModel.instance({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? updatedAt,
    String? loginPassword,
    String? userId,
    bool? isAnonymous,
    List<String>? chatRoomIds,
  }) {
    return UserModel(
      id: id ?? '',
      name: name ?? '名前はまだない',
      profilePhoto:
          "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      loginPassword: loginPassword ?? '',
      userId: userId ?? id ?? '',
      isAnonymous: isAnonymous ?? true,
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
