// ignore_for_file: overridden_fields

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String documentId;

  final String name;

  final String profilePhoto;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String loginPassword;

  /// ユーザが変えられるID　メンションに使用
  final String userId;

  final bool isAnonymous;

  List<String>? chatRoomIds;

  final bool isDeleted;

  UserModel({
    required this.documentId,
    required this.name,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.loginPassword,
    required this.userId,
    required this.isAnonymous,
    this.chatRoomIds,
    required this.isDeleted,
  });

  UserModel copyWith({
    String? documentId,
    String? name,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? loginPassword,
    String? userId,
    bool? isAnonymous,
    List<String>? chatRoomIds,
    bool? isDeleted,
  }) {
    return UserModel(
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      loginPassword: loginPassword ?? this.loginPassword,
      userId: userId ?? this.userId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      chatRoomIds: chatRoomIds ?? this.chatRoomIds,
      isDeleted: isDeleted ?? this.isDeleted,
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
    result.addAll({'isDeleted': isDeleted});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      documentId: map['\$id'] ?? '',
      name: map['name'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      loginPassword: map['loginPassword'] ?? '',
      userId: map['userId'] ?? '',
      isAnonymous: map['isAnonymous'] ?? true,
      chatRoomIds: List<String>.from(map['chatRoomIds']),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $documentId, name: $name, profilePhoto: $profilePhoto, createdAt: $createdAt, updatedAt: $updatedAt, loginPassword: $loginPassword, userId: $userId, isAnonymous: $isAnonymous   chatRoomIds: $chatRoomIds isDeleted: $isDeleted )';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.documentId == documentId &&
        other.name == name &&
        other.profilePhoto == profilePhoto &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.loginPassword == loginPassword &&
        other.userId == userId &&
        other.isAnonymous == isAnonymous &&
        listEquals(other.chatRoomIds, chatRoomIds) &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode =>
      documentId.hashCode ^
      name.hashCode ^
      profilePhoto.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      loginPassword.hashCode ^
      userId.hashCode ^
      isAnonymous.hashCode ^
      chatRoomIds.hashCode ^
      isDeleted.hashCode;

  factory UserModel.instance({
    String? documentId,
    String? name,
    String? profilePhoto,
    DateTime? updatedAt,
    String? loginPassword,
    String? userId,
    bool? isAnonymous,
    List<String>? chatRoomIds,
    bool? isDeleted,
  }) {
    return UserModel(
      documentId: documentId ?? '',
      name: name ?? '名前はまだない',
      profilePhoto:
          "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      loginPassword: loginPassword ?? '',
      userId: userId ?? documentId ?? '',
      isAnonymous: isAnonymous ?? true,
      chatRoomIds: chatRoomIds ?? [],
      isDeleted: isDeleted ?? false,
    );
  }

  static ChatUser toChatUser(UserModel userModel) {
    return ChatUser(
      id: userModel.documentId,
      name: userModel.name,
      profilePhoto: userModel.profilePhoto,
      userId: userModel.userId,
    );
  }
}
