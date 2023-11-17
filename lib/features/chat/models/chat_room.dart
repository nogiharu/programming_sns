import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:programming_sns/extensions/extensions.dart';

class ChatRoom {
  String? id;
  final String ownerId;
  final String name;
  // List<Message>? messages;

  final DateTime createdAt;

  final DateTime updatedAt;

  ChatRoom({
    this.id,
    required this.ownerId,
    required this.name,
    // this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatRoom copyWith({
    String? id,
    String? ownerId,
    String? name,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      // messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'ownerId': ownerId});
    result.addAll({'name': name});
    // if (messages != null) {
    //   result.addAll({'messages': messages!.map((x) => x.toMap()).toList()});
    // }
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'updatedAt': updatedAt.millisecondsSinceEpoch});
    return result;
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['\$id'],
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      // messages: map['messages'] != null
      //     ? List<Message>.from(map['messages']?.map((x) => MessageEX.fromMap(x)))
      //     : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'ChatRoom(id: $id, ownerId: $ownerId, name: $name,  $createdAt, updatedAt: $updatedAt )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
    // listEquals(other.messages, messages);
  }

  @override
  int get hashCode {
    return id.hashCode ^ ownerId.hashCode ^ name.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
    // messages.hashCode;
  }

  factory ChatRoom.instance({
    String? ownerId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ChatRoom(
        ownerId: ownerId ?? '',
        name: name ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}
