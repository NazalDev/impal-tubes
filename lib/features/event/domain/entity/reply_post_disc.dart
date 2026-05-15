class ReplyPostDiscEntity {
  final String id;
  final String postId; // maps to post_id / comment_id
  final String userId;
  final String body;
  final DateTime createdAt;
  final String? userAvatarUrl;
  final String? userName;

  const ReplyPostDiscEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.userAvatarUrl,
    this.userName,
  });
}
