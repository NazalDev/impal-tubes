import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
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

  /// [avatarFile] — if provided, uploads the file and uses the resulting URL.
  /// Pass `null` to leave the avatar unchanged.
  Future<Either<Failure, void>> editProfile({
    String? username,
    File? avatarFile,
    String? oldPassword,
    String? newPassword,
  });

  Future<Either<Failure, void>> resetPassword({
    required String username,
    required String email,
    required String newPassword,
  });
}
