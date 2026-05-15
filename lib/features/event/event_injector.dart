import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/features/event/data/datasource/event_remote_datasource.dart';
import 'package:volync/features/event/domain/usecase/create_event_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_events_usecase.dart';
import 'package:volync/features/event/domain/usecase/get_post_disc_usecase.dart';

import 'data/repositories/event_repository_impl.dart';

import 'presentation/bloc/event_bloc.dart';

/// Simple manual DI — call EventInjector.eventBloc() to get a ready BLoC.
/// Replace with get_it/injectable later if the project grows.
class EventInjector {
  static final _dataSource = EventRemoteDataSourceImpl(
    Supabase.instance.client,
  );

  static final _eventRepo = EventRepositoryImpl(_dataSource);
  static final _commentRepo = PostDiscRepositoryImpl(_dataSource);

  static EventBloc eventBloc() => EventBloc(
    getEventsUseCase: GetEventsUseCase(_eventRepo),
    createEventUseCase: CreateEventUseCase(_eventRepo),
  );

  static GetPostDiscsUseCase get getCommentsUseCase =>
      GetPostDiscsUseCase(_commentRepo);

  static GetRepliesUseCase get getRepliesUseCase =>
      GetRepliesUseCase(_commentRepo);
}
