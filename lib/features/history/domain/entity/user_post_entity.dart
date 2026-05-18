class UserPostEntity {
  final String id;
  final int eventId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final String eventTitle;
  final String? eventImageUrl;
  final bool isReply;
  final String? parentPostId; // non-null when isReply == true

  const UserPostEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.eventTitle,
    this.eventImageUrl,
    required this.isReply,
    this.parentPostId,
  });
}
