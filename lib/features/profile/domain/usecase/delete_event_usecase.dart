import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class DeleteEventUseCase implements UseCase<void, DeleteEventParams> {
  final ProfileRepository _profileRepository;

  DeleteEventUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(DeleteEventParams params) {
    return _profileRepository.deleteEvent(eventId: params.eventId);
  }
}

class DeleteEventParams {
  final String eventId;
  const DeleteEventParams({required this.eventId});
}
