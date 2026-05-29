// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:volync/core/common/entities/user.dart';
import 'package:volync/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> setAvatar(String url) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateUser({required String body}) {
    throw UnimplementedError();
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final user = await fn();
      return right(user);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> editProfile({
    String? username,
    File? avatarFile,
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      // 1. Upload avatar file if provided → get back a public URL
      final avatarUrl = await remoteDataSource.uploadAvatar(avatarFile);

      // 2. Update profile (passes URL string or null)
      await remoteDataSource.editProfile(
        username: username,
        avatarUrl: avatarUrl,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String username,
    required String email,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        username: username,
        email: email,
        newPassword: newPassword,
      );
      return right(null);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
