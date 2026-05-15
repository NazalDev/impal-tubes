import 'package:volync/features/event/domain/entity/reply_post_disc.dart';

class ReplyPostDiscModel extends ReplyPostDiscEntity {
  const ReplyPostDiscModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.body,
    required super.createdAt,
    super.userAvatarUrl,
    super.userName,
  });

  factory ReplyPostDiscModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] as Map<String, dynamic>?;

    return ReplyPostDiscModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      userName: user?['username'] as String? ?? 'Anonim',
      userAvatarUrl: user?['avatar_url'] as String?,
    );
  }
}
