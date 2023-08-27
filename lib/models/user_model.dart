// ignore_for_file: overridden_fields

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserModel extends ChatUser {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? profilePhoto;
  UserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
  }) : super(
          id: id,
          name: name,
          profilePhoto: profilePhoto,
        );

  UserModel copyWith({
    String? id,
    String? name,
    String? profilePhoto,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    if (profilePhoto != null) {
      result.addAll({'profilePhoto': profilePhoto});
    }

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      profilePhoto: map['profilePhoto'],
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.profilePhoto == profilePhoto;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ profilePhoto.hashCode;
}
