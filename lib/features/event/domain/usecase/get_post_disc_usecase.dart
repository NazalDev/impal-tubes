import 'package:volync/features/event/domain/entity/post_disc.dart';
import 'package:volync/features/event/domain/entity/reply_post_disc.dart';
import 'package:volync/features/event/domain/repository/post_disc_repository.dart';

class GetPostDiscsUseCase {
  GetPostDiscsUseCase(this.repository);

  final PostDiscRepository repository;

  Future<List<PostDiscEntity>> call({
    required int eventId,
    int limit = 5,
    int offset = 0,
  }) => repository.getComments(eventId: eventId, limit: limit, offset: offset);
}

class GetRepliesUseCase {
  GetRepliesUseCase(this.repository);

  final PostDiscRepository repository;

  Future<List<ReplyPostDiscEntity>> call({required String parentCommentId}) =>
      repository.getReplies(parentCommentId: parentCommentId);
}

class PostCommentUseCase {
  PostCommentUseCase(this.repository);

  final PostDiscRepository repository;

  Future<PostDiscEntity> call({
    required int eventId,
    required String userId,
    required String body,
  }) => repository.postComment(eventId: eventId, userId: userId, body: body);
}

class PostReplyUseCase {
  PostReplyUseCase(this.repository);

  final PostDiscRepository repository;

  Future<ReplyPostDiscEntity> call({
    required String postId,
    required String userId,
    required String body,
  }) => repository.postReply(postId: postId, userId: userId, body: body);
}