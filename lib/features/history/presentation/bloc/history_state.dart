part of 'history_bloc.dart';

@immutable
sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryRegistrationsLoaded extends HistoryState {
  final List<UserRegistrationEntity> registrations;
  HistoryRegistrationsLoaded(this.registrations);
}

final class HistoryPostsLoaded extends HistoryState {
  final List<UserPostEntity> posts;
  HistoryPostsLoaded(this.posts);
}

final class HistoryActionSuccess extends HistoryState {
  final String message;
  HistoryActionSuccess(this.message);
}

final class HistoryFailure extends HistoryState {
  final String message;
  HistoryFailure(this.message);
}
