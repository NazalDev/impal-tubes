class UserRegistrationEntity {
  final String id;
  final int eventId;
  final String userId;
  final String status; // pending | approved | rejected | cancelled
  final DateTime registeredAt;

  // Joined event fields
  final String eventTitle;
  final String eventLocation;
  final DateTime eventStartAt;
  final DateTime eventEndAt;
  final String eventStatus;
  final String? eventImageUrl;
  final String? eventGenre;
  final String eventDescription;

  const UserRegistrationEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    required this.eventTitle,
    required this.eventLocation,
    required this.eventStartAt,
    required this.eventEndAt,
    required this.eventStatus,
    this.eventImageUrl,
    this.eventGenre,
    required this.eventDescription,
  });
}
