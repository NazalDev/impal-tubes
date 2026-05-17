import 'package:volync/features/event/domain/repository/event_repository.dart';

class RegistEventUsecase {
  final EventRepository repository;
  RegistEventUsecase(this.repository);

  Future<void> call({required int eventId, required String userId}) {
    return repository.registerEvent(eventId, userId);
  }
}
