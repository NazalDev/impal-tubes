part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileLoadUserEvents extends ProfileEvent {
  final String userId;
  ProfileLoadUserEvents({required this.userId});
}

final class ProfileUpdateEvent extends ProfileEvent {
  final String eventId;
  final Map<String, dynamic> data;
  /// Optional local image file to upload as the event cover (max 2 MB,
  /// enforced in the UI layer before this event is dispatched).
  final File? imageFile;

  ProfileUpdateEvent({
    required this.eventId,
    required this.data,
    this.imageFile,
  });
}

final class ProfileDeleteEvent extends ProfileEvent {
  final String eventId;
  ProfileDeleteEvent({required this.eventId});
}

final class ProfileCancelEvent extends ProfileEvent {
  final String eventId;
  ProfileCancelEvent({required this.eventId});
}

final class ProfileLoadEventMembers extends ProfileEvent {
  final String eventId;
  ProfileLoadEventMembers({required this.eventId});
}

final class ProfileApproveMember extends ProfileEvent {
  final String registrationId;
  final String eventId;
  ProfileApproveMember({required this.registrationId, required this.eventId});
}

final class ProfileRejectMember extends ProfileEvent {
  final String registrationId;
  final String eventId;
  ProfileRejectMember({required this.registrationId, required this.eventId});
}

final class ProfileSignOut extends ProfileEvent {}
