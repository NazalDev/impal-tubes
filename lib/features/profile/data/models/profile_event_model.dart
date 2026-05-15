import 'dart:ffi';

import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';

class ProfileEventModel extends ProfileEventEntity {
  const ProfileEventModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.location,
    required super.status,
    required super.startAt,
    required super.endAt,
    super.createdAt,
    super.updatedAt,
    super.imageUrl,
    super.memberCount,
  });

  factory ProfileEventModel.fromMap(Map<String, dynamic> map) {
    return ProfileEventModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      status: map['status'] as String,
      startAt: DateTime.parse(map['start_at'] as String),
      endAt: DateTime.parse(map['end_at'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      imageUrl: map['image_url'] as String?,
      memberCount: map['member_count'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'location': location,
    'status': status,
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    if (imageUrl != null) 'image_url': imageUrl,
  };
}
