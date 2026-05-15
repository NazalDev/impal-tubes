import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class GetUserEventsUseCase
    implements UseCase<List<ProfileEventEntity>, GetUserEventsParams> {
  final ProfileRepository _profileRepository;

  GetUserEventsUseCase(this._profileRepository);

  @override
  Future<Either<Failure, List<ProfileEventEntity>>> call(
    GetUserEventsParams params,
  ) {
    return _profileRepository.getUserEvents(userId: params.userId);
  }
}

class GetUserEventsParams {
  final String userId;
  const GetUserEventsParams({required this.userId});
}
