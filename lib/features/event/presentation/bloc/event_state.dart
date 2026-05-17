part of 'event_bloc.dart';

abstract class EventBlocState {}

class EventInitial extends EventBlocState {}

class EventLoading extends EventBlocState {}

class EventLoaded extends EventBlocState {
  final List<EventEntity> events;
  final bool hasMore;
  final String activeFilter;
  final String searchQuery;

  EventLoaded({
    required this.events,
    required this.hasMore,
    this.activeFilter = 'Semua',
    this.searchQuery = '',
  });

  EventLoaded copyWith({
    List<EventEntity>? events,
    bool? hasMore,
    String? activeFilter,
    String? searchQuery,
  }) {
    return EventLoaded(
      events: events ?? this.events,
      hasMore: hasMore ?? this.hasMore,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class EventError extends EventBlocState {
  final String message;
  EventError(this.message);
}

// Separate states for the create flow so the list page isn't affected
class EventCreating extends EventBlocState {}

class EventCreated extends EventBlocState {}

class EventCreateError extends EventBlocState {
  final String message;
  EventCreateError(this.message);
}

//REGISTERATION
class EventRegistering extends EventBlocState {}

class EventRegistered extends EventBlocState {}

class EventRegisterError extends EventBlocState {
  final String message;
  EventRegisterError(this.message);
}

class ResetEventState extends EventBlocEvent {}
