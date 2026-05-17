import 'package:volync/features/event/domain/entity/event.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getEvents({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  });

  Future<void> createEvent(EventEntity event);
  Future<void> registerEvent(int eventId, String userId);
}
