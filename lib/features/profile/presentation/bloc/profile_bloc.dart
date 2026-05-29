import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';
import 'package:volync/features/profile/domain/usecase/cancel_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/delete_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/get_event_members_usecase.dart';
import 'package:volync/features/profile/domain/usecase/get_user_events_usecase.dart';
import 'package:volync/features/profile/domain/usecase/sign_out_usecase.dart';
import 'package:volync/features/profile/domain/usecase/update_event_usecase.dart';
import 'package:volync/features/profile/domain/usecase/update_member_status_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserEventsUseCase _getUserEvents;
  final UpdateEventUseCase _updateEvent;
  final DeleteEventUseCase _deleteEvent;
  final CancelEventUseCase _cancelEvent;
  final GetEventMembersUseCase _getEventMembers;
  final UpdateMemberStatusUseCase _updateMemberStatus;
  final SignOutUseCase _signOut;

  ProfileBloc({
    required GetUserEventsUseCase getUserEvents,
    required UpdateEventUseCase updateEvent,
    required DeleteEventUseCase deleteEvent,
    required CancelEventUseCase cancelEvent,
    required GetEventMembersUseCase getEventMembers,
    required UpdateMemberStatusUseCase updateMemberStatus,
    required SignOutUseCase signOut,
  }) : _getUserEvents = getUserEvents,
       _updateEvent = updateEvent,
       _deleteEvent = deleteEvent,
       _cancelEvent = cancelEvent,
       _getEventMembers = getEventMembers,
       _updateMemberStatus = updateMemberStatus,
       _signOut = signOut,
       super(ProfileInitial()) {
    on<ProfileLoadUserEvents>(_onLoadUserEvents);
    on<ProfileUpdateEvent>(_onUpdateEvent);
    on<ProfileDeleteEvent>(_onDeleteEvent);
    on<ProfileCancelEvent>(_onCancelEvent);
    on<ProfileLoadEventMembers>(_onLoadEventMembers);
    on<ProfileApproveMember>(_onApproveMember);
    on<ProfileRejectMember>(_onRejectMember);
    on<ProfileSignOut>(_onSignOut);
  }

  Future<void> _onLoadUserEvents(
    ProfileLoadUserEvents event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _getUserEvents(
      GetUserEventsParams(userId: event.userId),
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (events) => emit(ProfileUserEventsLoaded(events)),
    );
  }

  Future<void> _onUpdateEvent(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _updateEvent(
      UpdateEventParams(
        eventId: event.eventId,
        data: event.data,
        imageFile: event.imageFile,
      ),
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(ProfileActionSuccess('Event berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteEvent(
    ProfileDeleteEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _deleteEvent(DeleteEventParams(eventId: event.eventId));
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(ProfileActionSuccess('Event berhasil dihapus')),
    );
  }

  Future<void> _onCancelEvent(
    ProfileCancelEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _cancelEvent(CancelEventParams(eventId: event.eventId));
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(ProfileActionSuccess('Event berhasil dibatalkan')),
    );
  }

  Future<void> _onLoadEventMembers(
    ProfileLoadEventMembers event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _getEventMembers(
      GetEventMembersParams(eventId: event.eventId),
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (members) => emit(
        ProfileEventMembersLoaded(members: members, eventId: event.eventId),
      ),
    );
  }

  Future<void> _onApproveMember(
    ProfileApproveMember event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _updateMemberStatus(
      UpdateMemberStatusParams(
        registrationId: event.registrationId,
        status: 'approved',
      ),
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) {
        emit(ProfileActionSuccess('Anggota berhasil disetujui'));
        add(ProfileLoadEventMembers(eventId: event.eventId));
      },
    );
  }

  Future<void> _onRejectMember(
    ProfileRejectMember event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _updateMemberStatus(
      UpdateMemberStatusParams(
        registrationId: event.registrationId,
        status: 'rejected',
      ),
    );
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) {
        emit(ProfileActionSuccess('Anggota berhasil ditolak'));
        add(ProfileLoadEventMembers(eventId: event.eventId));
      },
    );
  }

  Future<void> _onSignOut(
    ProfileSignOut event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final res = await _signOut(NoParams());
    res.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(ProfileSignOutSuccess()),
    );
  }
}
