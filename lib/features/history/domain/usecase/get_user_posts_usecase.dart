import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/history/domain/entity/user_post_entity.dart';
import 'package:volync/features/history/domain/repository/history_repository.dart';

class GetUserPostsUseCase
    implements UseCase<List<UserPostEntity>, GetUserPostsParams> {
  final HistoryRepository _repository;
  GetUserPostsUseCase(this._repository);

  @override
  Future<Either<Failure, List<UserPostEntity>>> call(
    GetUserPostsParams params,
  ) {
    return _repository.getUserPosts(userId: params.userId);
  }
}

class GetUserPostsParams {
  final String userId;
  const GetUserPostsParams({required this.userId});
}
