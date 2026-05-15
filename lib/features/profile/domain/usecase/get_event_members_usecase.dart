import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class GetEventMembersUseCase
    implements UseCase<List<ProfileMemberEntity>, GetEventMembersParams> {
  final ProfileRepository _profileRepository;

  GetEventMembersUseCase(this._profileRepository);

  @override
  Future<Either<Failure, List<ProfileMemberEntity>>> call(
    GetEventMembersParams params,
  ) {
    return _profileRepository.getEventMembers(eventId: params.eventId);
  }
}

class GetEventMembersParams {
  final String eventId;
  const GetEventMembersParams({required this.eventId});
}
