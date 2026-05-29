class ProfileEventEntity {
  final String id;
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
  final int? memberCount;
  final int? quota;
  final String? genre;

  const ProfileEventEntity(
    this.genre, {
    required this.id,
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
    this.memberCount,
    this.quota,
  });

  ProfileEventEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    String? status,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    int? memberCount,
    int? quota,
    String? genre,
  }) {
    return ProfileEventEntity(
      genre ?? this.genre,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      memberCount: memberCount ?? this.memberCount,
      quota: quota ?? this.quota,
    );
  }
}
