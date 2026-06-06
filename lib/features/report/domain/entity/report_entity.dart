class ReportEntity {
  final String id;
  final String reporterUserId;
  final String? reportedUserId;
  final String? reportedEventId;
  final String reason;
  final String? description;
  final String status; // 'pending' | 'seen'
  final DateTime createdAt;

  // joined data
  final String? reporterUsername;
  final String? reportedUsername;
  final String? reportedEventTitle;

  const ReportEntity({
    required this.id,
    required this.reporterUserId,
    this.reportedUserId,
    this.reportedEventId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    this.reporterUsername,
    this.reportedUsername,
    this.reportedEventTitle,
  });

  bool get isEventReport => reportedEventId != null;
  bool get isUserReport => reportedUserId != null;
}
