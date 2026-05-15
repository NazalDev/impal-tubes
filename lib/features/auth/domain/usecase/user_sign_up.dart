import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/core/common/entities/user.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      username: params.username,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String username;
  final String email;
  final String password;

  UserSignUpParams({
    required this.username,
    required this.email,
    required this.password,
  });
}
