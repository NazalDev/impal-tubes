part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

final class HistoryLoadRegistrations extends HistoryEvent {
  final String userId;
  HistoryLoadRegistrations({required this.userId});
}

final class HistoryCancelRegistration extends HistoryEvent {
  final String registrationId;
  final String userId; // to reload after cancel
  HistoryCancelRegistration({
    required this.registrationId,
    required this.userId,
  });
}

final class HistoryLoadPosts extends HistoryEvent {
  final String userId;
  HistoryLoadPosts({required this.userId});
}
