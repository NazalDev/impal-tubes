import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/history/data/datasource/history_remote_datasource.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';
import 'package:volync/features/history/domain/repository/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _dataSource;
  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<UserRegistrationEntity>>> getUserRegistrations({
    required String userId,
  }) async {
    try {
      final result = await _dataSource.getUserRegistrations(userId: userId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRegistration({
    required String registrationId,
  }) async {
    try {
      await _dataSource.cancelRegistration(registrationId: registrationId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserPostEntity>>> getUserPosts({
    required String userId,
  }) async {
    try {
      final result = await _dataSource.getUserPosts(userId: userId);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
