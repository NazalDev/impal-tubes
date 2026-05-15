import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class UpdateEventUseCase implements UseCase<void, UpdateEventParams> {
  final ProfileRepository _profileRepository;

  UpdateEventUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(UpdateEventParams params) {
    return _profileRepository.updateEvent(
      eventId: params.eventId,
      data: params.data,
    );
  }
}

class UpdateEventParams {
  final String eventId;
  final Map<String, dynamic> data;
  const UpdateEventParams({required this.eventId, required this.data});
}
