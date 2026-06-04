import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/usecase/get_calendar_events_usecase.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getEvents({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  });

  Future<void> createEvent(EventEntity event);

  Future<void> registerEvent(int eventId, String userId);

  /// Fetches every event joined with the current user's registration row.
  Future<List<EventWithRegistration>> getCalendarEvents({
    required String userId,
  });

  /// Returns `true` if the user already has a registration row for [eventId].
  Future<bool> isUserRegistered({
    required int eventId,
    required String userId,
  });
}