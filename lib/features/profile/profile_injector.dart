import 'package:volync/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:volync/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';
import 'package:volync/features/profile/domain/usecase/cancel_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/delete_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/get_event_members_usecase.dart';
import 'package:volync/features/profile/domain/usecase/get_user_events_usecase.dart';
import 'package:volync/features/profile/domain/usecase/sign_out_usecase.dart';
import 'package:volync/features/profile/domain/usecase/update_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/update_member_status_usecase.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:volync/init_dependencies.dart';

void initProfile() {
  // DataSource
  serviceLocator.registerFactory<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(serviceLocator()),
  );

  // Repository
  serviceLocator.registerFactory<ProfileRepository>(
    () => ProfileRepositoryImpl(serviceLocator()),
  );

  // Use Cases
  serviceLocator.registerFactory(
    () => GetUserEventsUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UpdateEventUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => DeleteEventUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => CancelEventUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => GetEventMembersUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UpdateMemberStatusUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => SignOutUseCase(serviceLocator()),
  );

  // Bloc
  serviceLocator.registerLazySingleton(
    () => ProfileBloc(
      getUserEvents: serviceLocator(),
      updateEvent: serviceLocator(),
      deleteEvent: serviceLocator(),
      cancelEvent: serviceLocator(),
      getEventMembers: serviceLocator(),
      updateMemberStatus: serviceLocator(),
      signOut: serviceLocator(),
    ),
  );
}
