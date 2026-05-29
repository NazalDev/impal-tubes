import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';

class EditProfileParams {
  final String? username;
  /// Local image file chosen by the user.  Uploaded to Storage inside the repo.
  final File? avatarFile;
  final String? oldPassword;
  final String? newPassword;

  EditProfileParams({
    this.username,
    this.avatarFile,
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
      avatarFile: params.avatarFile,
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}
