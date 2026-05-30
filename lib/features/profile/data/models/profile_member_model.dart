import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';

class ProfileMemberModel extends ProfileMemberEntity {
  const ProfileMemberModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.username,
    required super.email,
    required super.avatarUrl,
    required super.status,
    super.registeredAt,
  });

  factory ProfileMemberModel.fromMap(Map<String, dynamic> map) {
    // Supabase join: registration row with embedded user row
    // Supabase returns the join under the table name used in the select string.
    // The query uses 'user (...)' so the key is 'user'. Fall back to 'users'
    // in case the schema alias ever changes.
    final user = (map['user'] ?? map['users']) as Map<String, dynamic>? ?? {};
    return ProfileMemberModel(
      id: _safeStringCast(map['id']),
      eventId: _safeStringCast(map['event_id']),
      userId: _safeStringCast(map['user_id']),
      username: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      avatarUrl: user['avatar_url'] as String? ?? 'default',
      status: _safeStringCast(map['status']).trim().toLowerCase(),
      registeredAt: map['registered_at'] != null
          ? DateTime.parse(map['registered_at'] as String)
          : null,
    );
  }

  static String _safeStringCast(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }
}
