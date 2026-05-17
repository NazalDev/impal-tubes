part of 'event_bloc.dart';

@immutable
abstract class EventBlocEvent {}

class LoadEvents extends EventBlocEvent {
  final bool reset;
  final String? searchQuery;
  final String? statusFilter;

  LoadEvents({this.reset = false, this.searchQuery, this.statusFilter});
}

class SearchEvents extends EventBlocEvent {
  final String query;

  SearchEvents(this.query);
}

class FilterEvents extends EventBlocEvent {
  final String filter;

  FilterEvents(this.filter);
}

class CreateEvent extends EventBlocEvent {
  final EventEntity event;
  CreateEvent(this.event);
}

class RegisterEvent extends EventBlocEvent {
  final int eventId;
  final String userId;
  RegisterEvent({required this.eventId, required this.userId});
}
