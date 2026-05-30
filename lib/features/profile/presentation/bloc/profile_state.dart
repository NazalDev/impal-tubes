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

// Any write operation succeeded (delete, cancel, update)
final class ProfileActionSuccess extends ProfileState {
  final String message;
  ProfileActionSuccess(this.message);
}

// Approve / reject succeeded — carries the eventId so the UI can show a
// snackbar. The bloc re-fetches members inline, so the page must NOT dispatch
// another ProfileLoadEventMembers in response to this state.
final class ProfileMemberActionSuccess extends ProfileState {
  final String message;
  final String eventId;
  ProfileMemberActionSuccess({required this.message, required this.eventId});
}

final class ProfileSignOutSuccess extends ProfileState {}

final class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}
