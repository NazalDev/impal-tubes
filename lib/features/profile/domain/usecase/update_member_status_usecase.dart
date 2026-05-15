import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class UpdateMemberStatusUseCase
    implements UseCase<void, UpdateMemberStatusParams> {
  final ProfileRepository _profileRepository;

  UpdateMemberStatusUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(UpdateMemberStatusParams params) {
    return _profileRepository.updateMemberStatus(
      registrationId: params.registrationId,
      status: params.status,
    );
  }
}

class UpdateMemberStatusParams {
  final String registrationId;
  final String status; // 'approved' | 'rejected'
  const UpdateMemberStatusParams({
    required this.registrationId,
    required this.status,
  });
}
