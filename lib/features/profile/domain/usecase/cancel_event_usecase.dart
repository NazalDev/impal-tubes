import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class CancelEventUseCase implements UseCase<void, CancelEventParams> {
  final ProfileRepository _profileRepository;

  CancelEventUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(CancelEventParams params) {
    return _profileRepository.cancelEvent(eventId: params.eventId);
  }
}

class CancelEventParams {
  final String eventId;
  const CancelEventParams({required this.eventId});
}
