class EventEntity {
  final int id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? genre;
  final int? quota;

  const EventEntity({
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.startAt,
    required this.endAt,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    required this.id,
    this.genre,
    this.quota,
  });
}
