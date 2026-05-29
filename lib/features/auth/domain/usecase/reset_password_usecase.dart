import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';

class ResetPasswordParams {
  final String username;
  final String email;
  final String newPassword;

  ResetPasswordParams({
    required this.username,
    required this.email,
    required this.newPassword,
  });
}

class ResetPasswordUsecase {
  final AuthRepository repository;
  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      username: params.username,
      email: params.email,
      newPassword: params.newPassword,
    );
  }
}
