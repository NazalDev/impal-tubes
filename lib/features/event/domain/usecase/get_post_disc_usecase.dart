import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/repository/post_disc_repository.dart';

class GetPostDiscsUseCase {
  final PostDiscRepository repository;

  GetPostDiscsUseCase(this.repository);

  Future<List<PostDiscEntity>> call({
    required String eventId,
    int limit = 5,
    int offset = 0,
  }) {
    return repository.getComments(
      eventId: eventId,
      limit: limit,
      offset: offset,
    );
  }
}

class GetRepliesUseCase {
  final PostDiscRepository repository;
  GetRepliesUseCase(this.repository);

  Future<List<ReplyPostDiscEntity>> call({required String parentCommentId}) {
    // ← ReplyEntity
    return repository.getReplies(parentCommentId: parentCommentId);
  }
}
