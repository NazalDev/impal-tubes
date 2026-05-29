import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/secrets/app_secrets.dart';
import 'package:volync/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:volync/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';
import 'package:volync/features/auth/domain/usecase/current_user.dart';
import 'package:volync/features/auth/domain/usecase/edit_profile_usecase.dart';
import 'package:volync/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:volync/features/auth/domain/usecase/user_login.dart';
import 'package:volync/features/auth/domain/usecase/user_sign_up.dart';
import 'package:volync/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:volync/features/event/data/datasource/event_remote_datasource.dart';
import 'package:volync/features/event/data/repositories/event_repository_impl.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';
import 'package:volync/features/event/domain/repository/post_disc_repository.dart';
import 'package:volync/features/event/domain/usecase/create_event_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_calendar_events_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_events_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';
import 'package:volync/features/event/domain/usecase/regist_event_usecase.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';
import 'package:volync/features/history/history_injector.dart';
import 'package:volync/features/profile/profile_injector.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();

  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  _initEvent();
  initProfile();
  initHistory();

  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(serviceLocator()),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));
  serviceLocator.registerFactory(() => CurrentUser(serviceLocator()));
  serviceLocator.registerFactory(() => EditProfileUsecase(serviceLocator()));
  serviceLocator.registerFactory(() => ResetPasswordUsecase(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
      editProfile: serviceLocator(),
      resetPassword: serviceLocator(),
    ),
  );
}

void _initEvent() {
  serviceLocator.registerFactory<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(serviceLocator()),
  );

  serviceLocator.registerFactory<EventRepository>(
    () => EventRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerFactory<PostDiscRepository>(
    () => PostDiscRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerFactory(() => GetEventsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => CreateEventUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => RegistEventUsecase(serviceLocator()));
  serviceLocator.registerFactory(() => GetCalendarEventsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetPostDiscsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetRepliesUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => PostCommentUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => PostReplyUseCase(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => EventBloc(
      getEventsUseCase: serviceLocator(),
      createEventUseCase: serviceLocator(),
      registerEventUseCase: serviceLocator(),
      getCalendarEventsUseCase: serviceLocator(),
      eventRepository: serviceLocator(),
    ),
  );
}
