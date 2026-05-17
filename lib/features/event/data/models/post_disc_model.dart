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
    final user = map['user'] as Map<String, dynamic>?;

    return PostDiscModel(
      id: map['id'].toString(),
      eventId: map['event_id'].toString(),
      userId: map['user_id'].toString(),
      userName: user?['username'] as String? ?? 'Anonim',
      userAvatarUrl: user?['avatar_url'] as String?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
