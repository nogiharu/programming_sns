import 'package:chatview/chatview.dart';

class UserModel {
  final String id;

  final String name;

  final String? profilePhoto;

  final DateTime createdAt;

  final DateTime updatedAt;

  /// ユーザが変えられるID　メンションに使用
  final String mentionId;

  final String profileDetails;

  final bool isDeleted;

  UserModel({
    required this.id,
    required this.name,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.mentionId,
    required this.isDeleted,
    required this.profileDetails,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isDeleted,
    String? profileDetails,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mentionId: userId ?? mentionId,
      isDeleted: isDeleted ?? this.isDeleted,
      profileDetails: profileDetails ?? this.profileDetails,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'profile_photo': profilePhoto});

    result.addAll({'mention_id': mentionId});

    result.addAll({'is_deleted': isDeleted});

    result.addAll({'profile_details': profileDetails});

    result.addAll({'updated_at': DateTime.now().toString()});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      profilePhoto: map['profile_photo'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      updatedAt: DateTime.parse(map['updated_at']).toLocal(),
      mentionId: map['mention_id'],
      isDeleted: map['is_deleted'],
      profileDetails: map['profile_details'] ?? '', // 空にしとく
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, profilePhoto: $profilePhoto, profileDetails: $profileDetails, createdAt: $createdAt, updatedAt: $updatedAt, mentionId: $mentionId, isDeleted: $isDeleted )';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.profilePhoto == profilePhoto &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.mentionId == mentionId &&
        other.isDeleted == isDeleted &&
        other.profileDetails == profileDetails;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      profilePhoto.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      mentionId.hashCode ^
      isDeleted.hashCode ^
      profileDetails.hashCode;

  factory UserModel.instance({
    String? id,
    String? name,
    String? profilePhoto,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? password,
    String? userId,
    bool? isAnonymous,
    bool? isDeleted,
    String? profileDetails,
  }) {
    return UserModel(
      id: id ?? '',
      name: name ?? '名前はまだない',
      profilePhoto:
          "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png",
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      mentionId: userId ?? '',
      isDeleted: isDeleted ?? false,
      profileDetails: profileDetails ?? '',
    );
  }

  static ChatUser toChatUser(UserModel userModel) {
    return ChatUser(
      id: userModel.id,
      name: userModel.name,
      profilePhoto: userModel.profilePhoto,
      mentionId: userModel.mentionId,
    );
  }
}
