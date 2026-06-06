import 'package:volync/features/report/data/datasource/report_remote_datasource.dart';
import 'package:volync/features/report/data/repositories/report_repository_impl.dart';
import 'package:volync/features/report/domain/repository/report_repository.dart';
import 'package:volync/features/report/domain/usecase/report_usecases.dart';
import 'package:volync/features/report/presentation/bloc/report_bloc.dart';
import 'package:volync/init_dependencies.dart';

void initReport() {
  serviceLocator.registerFactory<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(serviceLocator()),
  );

  serviceLocator.registerFactory<ReportRepository>(
    () => ReportRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerFactory(() => SubmitReportUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllReportsUseCase(serviceLocator()));
  serviceLocator.registerFactory(
    () => MarkReportAsSeenUseCase(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => ReportBloc(
      submitReport: serviceLocator(),
      getAllReports: serviceLocator(),
      markAsSeen: serviceLocator(),
    ),
  );
}
