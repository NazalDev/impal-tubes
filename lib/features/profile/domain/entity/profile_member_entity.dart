class ProfileMemberEntity {
  final String id;
  final String eventId;
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime? registeredAt;

  const ProfileMemberEntity({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.status,
    this.registeredAt,
  });
}
