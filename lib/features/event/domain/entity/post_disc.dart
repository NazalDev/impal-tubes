class PostDiscEntity {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String body;
  final DateTime createdAt;

  const PostDiscEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.body,
    required this.createdAt,
  });
}
