import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';
import 'package:volync/features/history/domain/usecase/get_user_posts_usecase.dart';
import 'package:volync/features/history/domain/usecase/get_user_registrations_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetUserRegistrationsUseCase _getRegistrations;
  final CancelRegistrationUseCase _cancelRegistration;
  final GetUserPostsUseCase _getPosts;

  HistoryBloc({
    required GetUserRegistrationsUseCase getRegistrations,
    required CancelRegistrationUseCase cancelRegistration,
    required GetUserPostsUseCase getPosts,
  }) : _getRegistrations = getRegistrations,
       _cancelRegistration = cancelRegistration,
       _getPosts = getPosts,
       super(HistoryInitial()) {
    on<HistoryLoadRegistrations>(_onLoadRegistrations);
    on<HistoryCancelRegistration>(_onCancelRegistration);
    on<HistoryLoadPosts>(_onLoadPosts);
  }

  Future<void> _onLoadRegistrations(
    HistoryLoadRegistrations event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final res = await _getRegistrations(
      GetUserRegistrationsParams(userId: event.userId),
    );
    res.fold(
      (failure) => emit(HistoryFailure(failure.message)),
      (registrations) => emit(HistoryRegistrationsLoaded(registrations)),
    );
  }

  Future<void> _onCancelRegistration(
    HistoryCancelRegistration event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final res = await _cancelRegistration(
      CancelRegistrationParams(registrationId: event.registrationId),
    );
    await res.fold((failure) async => emit(HistoryFailure(failure.message)), (
      _,
    ) async {
      emit(HistoryActionSuccess('Pendaftaran berhasil dibatalkan'));
      // Reload registrations after cancel
      final reloadRes = await _getRegistrations(
        GetUserRegistrationsParams(userId: event.userId),
      );
      reloadRes.fold(
        (failure) => emit(HistoryFailure(failure.message)),
        (registrations) => emit(HistoryRegistrationsLoaded(registrations)),
      );
    });
  }

  Future<void> _onLoadPosts(
    HistoryLoadPosts event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final res = await _getPosts(GetUserPostsParams(userId: event.userId));
    res.fold(
      (failure) => emit(HistoryFailure(failure.message)),
      (posts) => emit(HistoryPostsLoaded(posts)),
    );
  }
}
