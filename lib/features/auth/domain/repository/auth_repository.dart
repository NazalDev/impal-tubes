import 'package:volync/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/common/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String username,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, void>> setAvatar(String url);
  Future<Either<Failure, void>> updateUser({required String body});
}
