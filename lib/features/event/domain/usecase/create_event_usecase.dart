import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/domain/repository/event_repository.dart';

class CreateEventUseCase {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  Future<void> call(EventEntity event) {
    return repository.createEvent(event);
  }
}
