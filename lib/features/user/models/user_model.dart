// ignore_for_file: overridden_fields

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;

  final String name;

  final String profilePhoto;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String loginPassword;

  final String loginId;

  final bool isAnonymous;

  // final bool isDeleted;

  const UserModel({
    required this.id,
    required this.name,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.loginPassword,
    required this.loginId,
    required this.isAnonymous,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? loginPassword,
    String? loginId,
    bool? isAnonymous,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      loginPassword: loginPassword ?? this.loginPassword,
      loginId: loginId ?? this.loginId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    result.addAll({'profilePhoto': profilePhoto});

    result.addAll({'loginPassword': loginPassword});
    result.addAll({'loginId': loginId});

    result.addAll({'isAnonymous': isAnonymous});

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
      loginId: map['loginId'] ?? '',
      isAnonymous: map['isAnonymous'] ?? true,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto, createdAt: $createdAt, updatedAt: $updatedAt, loginPassword: $loginPassword, loginId: $loginId, isAnonymous: $isAnonymous)';

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
        other.loginId == loginId &&
        other.isAnonymous == isAnonymous;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      profilePhoto.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      loginPassword.hashCode ^
      loginId.hashCode ^
      isAnonymous.hashCode;

  factory UserModel.instance({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? updatedAt,
    String? loginPassword,
    String? loginId,
    bool? isAnonymous,
  }) {
    return UserModel(
      id: id ?? '',
      name: name ?? 'ユーザーがいません！',
      profilePhoto:
          "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      loginPassword: loginPassword ?? '',
      loginId: loginId ?? '',
      isAnonymous: isAnonymous ?? true,
    );
  }

  static ChatUser toChatUser(UserModel userModel) {
    return ChatUser(
      id: userModel.id,
      name: userModel.name,
      profilePhoto: userModel.profilePhoto,
    );
  }
}
