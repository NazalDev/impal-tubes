import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/report/data/datasource/report_remote_datasource.dart';
import 'package:volync/features/report/domain/entity/report_entity.dart';
import 'package:volync/features/report/domain/repository/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;

  ReportRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> submitReport({
    required String? reportedUserId,
    required String? reportedEventId,
    required String reason,
    String? description,
  }) async {
    try {
      await _dataSource.submitReport(
        reportedUserId: reportedUserId,
        reportedEventId: reportedEventId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getAllReports() async {
    try {
      final reports = await _dataSource.getAllReports();
      return Right(reports);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markReportAsSeen({
    required String reportId,
  }) async {
    try {
      await _dataSource.markReportAsSeen(reportId: reportId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
