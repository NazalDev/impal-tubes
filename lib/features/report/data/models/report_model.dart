import 'package:volync/features/report/domain/entity/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.reporterUserId,
    super.reportedUserId,
    super.reportedEventId,
    required super.reason,
    super.description,
    required super.status,
    required super.createdAt,
    super.reporterUsername,
    super.reportedUsername,
    super.reportedEventTitle,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    final reporter = map['reporter'] as Map<String, dynamic>?;
    final reportedUser = map['reported_user'] as Map<String, dynamic>?;
    final reportedEvent = map['reported_event'] as Map<String, dynamic>?;

    return ReportModel(
      id: map['id'].toString(),
      reporterUserId: map['reporter_user_id'] as String,
      reportedUserId: map['reported_user_id'] as String?,
      reportedEventId: map['reported_event_id']?.toString(),
      reason: map['reason'] as String,
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
      reporterUsername: reporter?['username'] as String?,
      reportedUsername: reportedUser?['username'] as String?,
      reportedEventTitle: reportedEvent?['title'] as String?,
    );
  }
}
