import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';

class GetEventsUseCase {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  Future<List<EventEntity>> call({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
    String? statusFilter,
  }) {
    return repository.getEvents(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      statusFilter: statusFilter,
    );
  }
}
