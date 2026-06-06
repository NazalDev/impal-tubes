part of 'report_bloc.dart';

@immutable
sealed class ReportEvent {}

final class ReportSubmit extends ReportEvent {
  final String? reportedUserId;
  final String? reportedEventId;
  final String reason;
  final String? description;

  ReportSubmit({
    this.reportedUserId,
    this.reportedEventId,
    required this.reason,
    this.description,
  });
}

final class ReportLoadAll extends ReportEvent {}

final class ReportMarkSeen extends ReportEvent {
  final String reportId;
  ReportMarkSeen({required this.reportId});
}
