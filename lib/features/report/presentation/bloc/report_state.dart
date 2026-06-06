part of 'report_bloc.dart';

@immutable
sealed class ReportState {}

final class ReportInitial extends ReportState {}

final class ReportLoading extends ReportState {}

final class ReportLoaded extends ReportState {
  final List<ReportEntity> reports;
  ReportLoaded(this.reports);
}

final class ReportSubmitSuccess extends ReportState {
  ReportSubmitSuccess();
}

final class ReportMarkSeenSuccess extends ReportState {
  ReportMarkSeenSuccess();
}

final class ReportFailure extends ReportState {
  final String message;
  ReportFailure(this.message);
}
