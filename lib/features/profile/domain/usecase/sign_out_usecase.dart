import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final ProfileRepository _profileRepository;

  SignOutUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _profileRepository.signOut();
  }
}
