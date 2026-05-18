import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';

class EditProfileParams {
  final String? username;
  final String? avatarUrl;
  final String? oldPassword;
  final String? newPassword;

  EditProfileParams({
    this.username,
    this.avatarUrl,
    this.oldPassword,
    this.newPassword,
  });
}

class EditProfileUsecase {
  final AuthRepository repository;
  EditProfileUsecase(this.repository);

  Future<Either<Failure, void>> call(EditProfileParams params) async {
    return await repository.editProfile(
      username: params.username,
      avatarUrl: params.avatarUrl,
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}
