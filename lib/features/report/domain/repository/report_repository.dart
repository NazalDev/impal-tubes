import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/report/domain/entity/report_entity.dart';

abstract interface class ReportRepository {
  Future<Either<Failure, void>> submitReport({
    required String? reportedUserId,
    required String? reportedEventId,
    required String reason,
    String? description,
  });

  Future<Either<Failure, List<ReportEntity>>> getAllReports();
  Future<Either<Failure, void>> markReportAsSeen({required String reportId});
}
