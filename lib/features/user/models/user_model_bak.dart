// // ignore_for_file: overridden_fields

// import 'package:chatview/chatview.dart';
// import 'package:flutter/foundation.dart';

// @immutable
// class UserModel extends ChatUser {
//   @override
//   final String id;
//   @override
//   final String name;
//   @override
//   final String? profilePhoto;

//   final DateTime? createdAt;

//   final DateTime? updatedAt;

//   // final bool isDeleted;

//   UserModel({
//     required this.id,
//     required this.name,
//     this.profilePhoto,
//     required this.createdAt,
//     required this.updatedAt,
//   }) : super(
//           id: id,
//           name: name,
//           profilePhoto: profilePhoto,
//         );

//   UserModel copyWith({
//     String? id,
//     String? name,
//     String? profilePhoto,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       profilePhoto: profilePhoto ?? this.profilePhoto,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};

//     result.addAll({'name': name});
//     if (createdAt != null) {
//       result.addAll({'createdAt': createdAt!.millisecondsSinceEpoch});
//     }
//     if (updatedAt != null) {
//       result.addAll({'updatedAt': updatedAt!.millisecondsSinceEpoch});
//     }
//     if (profilePhoto != null) {
//       result.addAll({'profilePhoto': profilePhoto});
//     }

//     return result;
//   }

//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       id: map['\$id'] ?? '',
//       name: map['name'] ?? '',
//       profilePhoto: map['profilePhoto'] ?? '',
//       createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
//       updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
//     );
//   }

//   @override
//   String toString() =>
//       'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto, createdAt: $createdAt, updatedAt: $updatedAt)';

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is UserModel &&
//         other.id == id &&
//         other.name == name &&
//         other.profilePhoto == profilePhoto &&
//         other.createdAt == createdAt &&
//         other.updatedAt == updatedAt;
//   }

//   @override
//   int get hashCode =>
//       id.hashCode ^ name.hashCode ^ profilePhoto.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;

//   factory UserModel.instance({
//     String? id,
//     String? name,
//     String? profilePhoto,
//     DateTime? updatedAt,
//   }) {
//     return UserModel(
//       id: id ?? 'aaa',
//       name: name ?? 'HOGEEEE',
//       profilePhoto: '',
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
//   }
// }
