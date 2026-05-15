part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

// User events list loaded
final class ProfileUserEventsLoaded extends ProfileState {
  final List<ProfileEventEntity> events;
  ProfileUserEventsLoaded(this.events);
}

// Members of a specific event loaded
final class ProfileEventMembersLoaded extends ProfileState {
  final List<ProfileMemberEntity> members;
  final String eventId;
  ProfileEventMembersLoaded({required this.members, required this.eventId});
}

// Any write operation succeeded (delete, cancel, update, approve/reject)
final class ProfileActionSuccess extends ProfileState {
  final String message;
  ProfileActionSuccess(this.message);
}

final class ProfileSignOutSuccess extends ProfileState {}

final class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}
