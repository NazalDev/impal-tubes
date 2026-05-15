import 'package:volync/features/event/domain/entity/post_disc.dart';

class PostDiscModel extends PostDiscEntity {
  const PostDiscModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory PostDiscModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] as Map<String, dynamic>?;

    return PostDiscModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      userId: map['user_id'] as String,
      userName: user?['username'] as String? ?? 'Anonim',
      userAvatarUrl: user?['avatar_url'] as String?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
