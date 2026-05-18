import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';

abstract interface class HistoryRepository {
  Future<Either<Failure, List<UserRegistrationEntity>>> getUserRegistrations({
    required String userId,
  });

  Future<Either<Failure, void>> cancelRegistration({
    required String registrationId,
  });

  Future<Either<Failure, List<UserPostEntity>>> getUserPosts({
    required String userId,
  });
}
