import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/report/domain/entity/report_entity.dart';
import 'package:volync/features/report/domain/repository/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repo;
  SubmitReportUseCase(this._repo);

  Future<Either<Failure, void>> call({
    String? reportedUserId,
    String? reportedEventId,
    required String reason,
    String? description,
  }) =>
      _repo.submitReport(
        reportedUserId: reportedUserId,
        reportedEventId: reportedEventId,
        reason: reason,
        description: description,
      );
}

class GetAllReportsUseCase {
  final ReportRepository _repo;
  GetAllReportsUseCase(this._repo);

  Future<Either<Failure, List<ReportEntity>>> call() => _repo.getAllReports();
}

class MarkReportAsSeenUseCase {
  final ReportRepository _repo;
  MarkReportAsSeenUseCase(this._repo);

  Future<Either<Failure, void>> call({required String reportId}) =>
      _repo.markReportAsSeen(reportId: reportId);
}
