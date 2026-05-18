import 'package:volync/features/history/data/datasource/history_remote_datasource.dart';
import 'package:volync/features/history/data/repositories/history_repository_impl.dart';
import 'package:volync/features/history/domain/repository/history_repository.dart';
import 'package:volync/features/history/domain/usecase/get_user_posts_usecase.dart';
import 'package:volync/features/history/domain/usecase/get_user_registrations_usecase.dart';
import 'package:volync/features/history/presentation/bloc/history_bloc.dart';
import 'package:volync/init_dependencies.dart';

void initHistory() {
  // DataSource
  serviceLocator.registerFactory<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(serviceLocator()),
  );

  // Repository
  serviceLocator.registerFactory<HistoryRepository>(
    () => HistoryRepositoryImpl(serviceLocator()),
  );

  // Use Cases
  serviceLocator.registerFactory(
    () => GetUserRegistrationsUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => CancelRegistrationUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(() => GetUserPostsUseCase(serviceLocator()));

  // Bloc
  serviceLocator.registerFactory(
    () => HistoryBloc(
      getRegistrations: serviceLocator(),
      cancelRegistration: serviceLocator(),
      getPosts: serviceLocator(),
    ),
  );
}
