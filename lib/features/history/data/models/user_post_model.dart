import 'package:volync/features/history/domain/entity/user_post_entity.dart';

class UserPostModel extends UserPostEntity {
  const UserPostModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.body,
    required super.createdAt,
    required super.eventTitle,
    super.eventImageUrl,
    required super.isReply,
    super.parentPostId,
  });

  factory UserPostModel.fromPostMap(Map<String, dynamic> map) {
    final event = map['event'] as Map<String, dynamic>? ?? {};
    return UserPostModel(
      id: map['id'].toString(),
      eventId: _parseInt(map['event_id']),
      userId: map['user_id'].toString(),
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      eventTitle: event['title'] as String? ?? '',
      eventImageUrl: event['image_url'] as String?,
      isReply: false,
    );
  }

  factory UserPostModel.fromReplyMap(Map<String, dynamic> map) {
    // replies join through postdisc → event
    final post = map['postdisc'] as Map<String, dynamic>? ?? {};
    final event = post['event'] as Map<String, dynamic>? ?? {};
    return UserPostModel(
      id: map['id'].toString(),
      eventId: _parseInt(event['id'] ?? post['event_id'] ?? 0),
      userId: map['user_id'].toString(),
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      eventTitle: event['title'] as String? ?? '',
      eventImageUrl: event['image_url'] as String?,
      isReply: true,
      parentPostId: map['post_id'].toString(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
