import 'package:volync/features/history/domain/entity/user_registration_entity.dart';

class UserRegistrationModel extends UserRegistrationEntity {
  const UserRegistrationModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.status,
    required super.registeredAt,
    required super.eventTitle,
    required super.eventLocation,
    required super.eventStartAt,
    required super.eventEndAt,
    required super.eventStatus,
    super.eventImageUrl,
    super.eventGenre,
    required super.eventDescription,
  });

  factory UserRegistrationModel.fromMap(Map<String, dynamic> map) {
    final event = map['event'] as Map<String, dynamic>? ?? {};
    return UserRegistrationModel(
      id: map['id'].toString(),
      eventId: _parseInt(map['event_id']),
      userId: map['user_id'].toString(),
      status: map['status'] as String? ?? 'pending',
      registeredAt: DateTime.parse(map['registered_at'] as String),
      eventTitle: event['title'] as String? ?? '',
      eventLocation: event['location'] as String? ?? '',
      eventStartAt: DateTime.parse(event['start_at'] as String),
      eventEndAt: DateTime.parse(event['end_at'] as String),
      eventStatus: event['status'] as String? ?? '',
      eventImageUrl: event['image_url'] as String?,
      eventGenre: event['genre'] as String?,
      eventDescription: event['description'] as String? ?? '',
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
